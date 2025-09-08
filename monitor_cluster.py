#!/usr/bin/env python3
"""
BSC Cluster Monitor
Monitors the status of BSC nodes in the cluster
"""

import os
import yaml
import paramiko
import argparse
import time
import requests
from pathlib import Path
from typing import Dict, List, Any
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
import json

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class BSCClusterMonitor:
    def __init__(self, config_path: str):
        self.config = self.load_config(config_path)

    def load_config(self, config_path: str) -> Dict[str, Any]:
        """Load deployment configuration from YAML file"""
        with open(config_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)

    def create_ssh_client(self, server_config: Dict[str, Any]) -> paramiko.SSHClient:
        """Create SSH client for server connection"""
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            # Load SSH key
            private_key_path = os.path.expanduser(server_config['ssh_key'])
            private_key = paramiko.RSAKey.from_private_key_file(private_key_path)

            # Connect to server
            client.connect(
                hostname=server_config['host'],
                username=server_config['user'],
                pkey=private_key
            )

            return client

        except Exception as e:
            logger.error(f"Failed to connect to {server_config['name']}: {e}")
            raise

    def check_server_status(self, server_config: Dict[str, Any]) -> Dict[str, Any]:
        """Check status of BSC node on server"""
        server_name = server_config['name']
        server_host = server_config['host']
        http_port = server_config['ports']['http']

        status = {
            'server': server_name,
            'host': server_host,
            'container_status': 'unknown',
            'node_status': 'unknown',
            'block_height': 0,
            'peers': 0,
            'syncing': False,
            'errors': []
        }

        try:
            # Create SSH client
            ssh_client = self.create_ssh_client(server_config)

            # Check Docker container status
            container_name = server_config['name']
            stdin, stdout, stderr = ssh_client.exec_command(
                f"docker ps --filter name={container_name} --format '{{{{.Status}}}}'"
            )
            container_output = stdout.read().decode().strip()

            if container_output:
                status['container_status'] = 'running'

                # Check container health
                stdin, stdout, stderr = ssh_client.exec_command(
                    f"docker inspect {container_name} --format '{{{{.State.Health.Status}}}}'"
                )
                health_output = stdout.read().decode().strip()
                status['container_health'] = health_output if health_output else 'unknown'
            else:
                status['container_status'] = 'stopped'
                status['errors'].append('Container not running')

            ssh_client.close()

        except Exception as e:
            status['errors'].append(f'SSH connection failed: {str(e)}')

        # Check RPC endpoint
        try:
            rpc_url = f"http://{server_host}:{http_port}"
            response = requests.post(
                rpc_url,
                json={
                    "jsonrpc": "2.0",
                    "method": "eth_syncing",
                    "params": [],
                    "id": 1
                },
                timeout=5
            )

            if response.status_code == 200:
                result = response.json()
                if result.get('result'):
                    status['node_status'] = 'syncing'
                    status['syncing'] = True
                else:
                    status['node_status'] = 'synced'
            else:
                status['node_status'] = 'error'
                status['errors'].append(f'RPC returned status {response.status_code}')

        except requests.exceptions.RequestException as e:
            status['node_status'] = 'unreachable'
            status['errors'].append(f'RPC connection failed: {str(e)}')

        # Get block height
        if status['node_status'] in ['synced', 'syncing']:
            try:
                rpc_url = f"http://{server_host}:{http_port}"
                response = requests.post(
                    rpc_url,
                    json={
                        "jsonrpc": "2.0",
                        "method": "eth_blockNumber",
                        "params": [],
                        "id": 1
                    },
                    timeout=5
                )

                if response.status_code == 200:
                    result = response.json()
                    block_hex = result.get('result', '0x0')
                    status['block_height'] = int(block_hex, 16)

            except Exception as e:
                status['errors'].append(f'Failed to get block height: {str(e)}')

        # Get peer count
        if status['node_status'] in ['synced', 'syncing']:
            try:
                rpc_url = f"http://{server_host}:{http_port}"
                response = requests.post(
                    rpc_url,
                    json={
                        "jsonrpc": "2.0",
                        "method": "net_peerCount",
                        "params": [],
                        "id": 1
                    },
                    timeout=5
                )

                if response.status_code == 200:
                    result = response.json()
                    peer_hex = result.get('result', '0x0')
                    status['peers'] = int(peer_hex, 16)

            except Exception as e:
                status['errors'].append(f'Failed to get peer count: {str(e)}')

        return status

    def monitor_cluster(self, parallel: bool = True, max_parallel: int = 10) -> Dict[str, Any]:
        """Monitor all servers in the cluster"""
        logger.info("Starting cluster monitoring")

        servers = self.config['servers']
        cluster_status = {
            'timestamp': time.time(),
            'cluster_size': len(servers),
            'servers': {},
            'summary': {
                'total_servers': len(servers),
                'running_containers': 0,
                'healthy_nodes': 0,
                'syncing_nodes': 0,
                'synced_nodes': 0,
                'errors': []
            }
        }

        server_statuses = []

        if parallel and len(servers) > 1:
            with ThreadPoolExecutor(max_workers=max_parallel) as executor:
                futures = [
                    executor.submit(self.check_server_status, server)
                    for server in servers
                ]

                for future in as_completed(futures):
                    server_statuses.append(future.result())
        else:
            for server in servers:
                server_statuses.append(self.check_server_status(server))

        # Process results
        for status in server_statuses:
            server_name = status['server']
            cluster_status['servers'][server_name] = status

            # Update summary
            if status['container_status'] == 'running':
                cluster_status['summary']['running_containers'] += 1

            if status['node_status'] in ['synced', 'syncing']:
                cluster_status['summary']['healthy_nodes'] += 1

            if status['node_status'] == 'syncing':
                cluster_status['summary']['syncing_nodes'] += 1

            if status['node_status'] == 'synced':
                cluster_status['summary']['synced_nodes'] += 1

            if status['errors']:
                cluster_status['summary']['errors'].extend(status['errors'])

        logger.info(f"Monitoring completed. {cluster_status['summary']['running_containers']}/{len(servers)} containers running")
        return cluster_status

    def print_status_report(self, cluster_status: Dict[str, Any]):
        """Print formatted status report"""
        print("\n" + "="*80)
        print("BSC CLUSTER STATUS REPORT")
        print("="*80)
        print(f"Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(cluster_status['timestamp']))}")
        print(f"Cluster Size: {cluster_status['cluster_size']}")
        print()

        # Summary
        summary = cluster_status['summary']
        print("SUMMARY:")
        print(f"  Total Servers: {summary['total_servers']}")
        print(f"  Running Containers: {summary['running_containers']}")
        print(f"  Healthy Nodes: {summary['healthy_nodes']}")
        print(f"  Syncing Nodes: {summary['syncing_nodes']}")
        print(f"  Synced Nodes: {summary['synced_nodes']}")
        print()

        # Server details
        print("SERVER DETAILS:")
        print("-" * 80)
        print("<15"        print("-" * 80)

        for server_name, status in cluster_status['servers'].items():
            container_status = status['container_status']
            node_status = status['node_status']
            block_height = status['block_height']
            peers = status['peers']

            print("<15")

            if status['errors']:
                print(f"    Errors: {', '.join(status['errors'])}")

        print()

        # Errors summary
        if summary['errors']:
            print("CLUSTER ERRORS:")
            for error in summary['errors'][:5]:  # Show first 5 errors
                print(f"  - {error}")
            if len(summary['errors']) > 5:
                print(f"  ... and {len(summary['errors']) - 5} more errors")
            print()

    def start_continuous_monitoring(self, interval: int = 60):
        """Start continuous monitoring"""
        logger.info(f"Starting continuous monitoring (interval: {interval}s)")

        try:
            while True:
                cluster_status = self.monitor_cluster()
                self.print_status_report(cluster_status)

                print(f"\nWaiting {interval} seconds before next check...")
                time.sleep(interval)

        except KeyboardInterrupt:
            logger.info("Monitoring stopped by user")
        except Exception as e:
            logger.error(f"Monitoring failed: {e}")


def main():
    parser = argparse.ArgumentParser(description="BSC Cluster Monitor")
    parser.add_argument("--config", default="deployment-config.yaml", help="Path to deployment config file")
    parser.add_argument("--continuous", action="store_true", help="Enable continuous monitoring")
    parser.add_argument("--interval", type=int, default=60, help="Monitoring interval in seconds")
    parser.add_argument("--parallel", action="store_true", help="Enable parallel monitoring")
    parser.add_argument("--max-parallel", type=int, default=10, help="Maximum parallel workers")
    parser.add_argument("--output", choices=['console', 'json', 'yaml'], default='console', help="Output format")

    args = parser.parse_args()

    # Validate config file
    if not os.path.exists(args.config):
        logger.error(f"Configuration file not found: {args.config}")
        return 1

    try:
        monitor = BSCClusterMonitor(args.config)

        if args.continuous:
            monitor.start_continuous_monitoring(args.interval)
        else:
            cluster_status = monitor.monitor_cluster(
                parallel=args.parallel,
                max_parallel=args.max_parallel
            )

            if args.output == 'console':
                monitor.print_status_report(cluster_status)
            elif args.output == 'json':
                print(json.dumps(cluster_status, indent=2))
            elif args.output == 'yaml':
                print(yaml.dump(cluster_status, default_flow_style=False))

        return 0

    except Exception as e:
        logger.error(f"Monitoring failed: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
