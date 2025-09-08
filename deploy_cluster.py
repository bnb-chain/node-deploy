#!/usr/bin/env python3
"""
BSC Cluster Deployment Script
Deploys BSC nodes to multiple servers using Docker
"""

import os
import yaml
import paramiko
import argparse
import subprocess
import time
from pathlib import Path
from typing import Dict, List, Any
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
from file_distributor import FileDistributor

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class BSCClusterDeployer:
    def __init__(self, config_path: str):
        self.config = self.load_config(config_path)
        self.distributor = FileDistributor(config_path)

    def load_config(self, config_path: str) -> Dict[str, Any]:
        """Load deployment configuration from YAML file"""
        with open(config_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)

    def create_ssh_client(self, server_config: Dict[str, Any]) -> paramiko.SSHClient:
        """Create SSH client for server connection"""
        return self.distributor.create_ssh_client(server_config)

    def build_docker_image(self) -> bool:
        """Build Docker image locally"""
        logger.info("Building Docker image...")

        try:
            # Check if Dockerfile exists
            if not os.path.exists("Dockerfile"):
                logger.error("Dockerfile not found in current directory")
                return False

            # Build Docker image
            image_name = self.config['docker']['image_name']
            image_tag = self.config['docker']['image_tag']

            cmd = f"docker build -t {image_name}:{image_tag} ."
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode != 0:
                logger.error(f"Docker build failed: {result.stderr}")
                return False

            logger.info(f"Docker image {image_name}:{image_tag} built successfully")
            return True

        except Exception as e:
            logger.error(f"Error building Docker image: {e}")
            return False

    def push_docker_image(self) -> bool:
        """Push Docker image to registry"""
        registry = self.config['docker'].get('registry', '')
        if not registry:
            logger.info("No registry configured, skipping push")
            return True

        logger.info(f"Pushing Docker image to registry: {registry}")

        try:
            image_name = self.config['docker']['image_name']
            image_tag = self.config['docker']['image_tag']

            # Tag image for registry
            registry_image = f"{registry}/{image_name}:{image_tag}"

            # Tag the image
            tag_cmd = f"docker tag {image_name}:{image_tag} {registry_image}"
            result = subprocess.run(tag_cmd, shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                logger.error(f"Docker tag failed: {result.stderr}")
                return False

            # Push the image
            push_cmd = f"docker push {registry_image}"
            result = subprocess.run(push_cmd, shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                logger.error(f"Docker push failed: {result.stderr}")
                return False

            logger.info(f"Docker image pushed to {registry_image}")
            return True

        except Exception as e:
            logger.error(f"Error pushing Docker image: {e}")
            return False

    def deploy_to_server(self, server_config: Dict[str, Any]) -> bool:
        """Deploy SimpleChain2 node to a specific server"""
        server_name = server_config['name']
        role = server_config['role']  # Get role from server config
        ports = server_config['ports']  # Get ports from server config
        node_index = server_config['node_index']  # Get node index

        logger.info(f"Starting deployment to {server_name}")
        current_dir = Path(__file__).resolve().parent

        # Get validator address for validator nodes
        validator_address = "0x0000000000000000000000000000000000000000"
        if role == 'validator':
            validator_address = self.get_validator_address(node_index)
            logger.info(f"Using validator address: {validator_address}")

        try:
            # Create SSH client
            ssh_client = self.create_ssh_client(server_config)

            # Create remote directories (use user home directory instead of /opt)
            remote_base = f"{current_dir}/sipc2/{server_name}"
            self.distributor.ensure_remote_directory(ssh_client, remote_base)
            self.distributor.ensure_remote_directory(ssh_client, f"{remote_base}/data")

            # Generate Docker run command with correct validator address
            docker_cmd = self.generate_docker_run_command(server_config, validator_address)
            print(docker_cmd)
            data_dir = f"{current_dir}/sipc2/{server_name}/data"
            # Create deployment script
            if role == 'validator':
                deployment_script = f"""#!/bin/bash
set -e

echo "Starting BSC validator node deployment on {server_name}"

# Stop existing container if running
docker stop {server_name} 2>/dev/null || true
docker rm {server_name} 2>/dev/null || true

# Run Docker container
{docker_cmd}

echo "BSC validator node deployment completed on {server_name}"

# Wait for node to be ready for staking
echo "Waiting for node to be ready for staking..."
sleep 45

# Register validator and stake tokens
echo "Registering validator and staking tokens..."
# Note: This requires the create-validator tool and proper configuration
# The actual staking command should be added here based on your setup
# Example command structure:
# create-validator --consensus-key-dir ~/sipc2/{server_name}/keys/validator \\
#                  --vote-key-dir ~/sipc2/{server_name}/keys/bls \\
#                  --password-path ~/sipc2/{server_name}/keys/password.txt \\
#                  --amount 20001 \\
#                  --validator-desc {server_name} \\
#                  -rpc-url http://localhost:{ports['http']}

echo "Validator registration and staking completed"
"""
            else:
                # Check if we should clean data directory
                clean_data = self.config['options'].get('clean_before_deploy', True)

                deployment_script = f"""#!/bin/bash
set -e

echo "Starting BSC {role} node deployment on {server_name}"

# Stop existing container if running
docker stop {server_name} 2>/dev/null || true
docker rm {server_name} 2>/dev/null || true

# Clean up mounted data directory to prevent dirty data issues
if [ "{clean_data}" = "True" ]; then
    echo "Cleaning up data directory to prevent dirty data..."
    if [ -d "{data_dir}" ]; then
        rm -rf {data_dir}/*
        find {data_dir} -name ".*" -type f -delete 2>/dev/null || true
    fi
else
    echo "Skipping data directory cleanup (clean_before_deploy=False)"
fi

# Run Docker container
{docker_cmd}

echo "BSC {role} node deployment completed on {server_name}"
"""

            # Upload and execute deployment script
            remote_script_path = f"{remote_base}/deploy.sh"
            with ssh_client.open_sftp() as sftp:
                with sftp.file(remote_script_path, 'w') as f:
                    f.write(deployment_script)

            # Make script executable and run it
            stdin, stdout, stderr = ssh_client.exec_command(f"chmod +x {remote_script_path} && {remote_script_path}")
            exit_code = stdout.channel.recv_exit_status()

            if exit_code != 0:
                error = stderr.read().decode()
                logger.error(f"Deployment failed on {server_name}: {error}")
                ssh_client.close()
                return False

            # If this is a validator node, register and stake tokens
            if role == 'validator':
                logger.info(f"Validator node deployed, proceeding with staking registration for {server_name}")
                if not self.register_validator_stake(server_config, ssh_client, validator_address):
                    logger.warning(f"Staking registration failed for {server_name}, but deployment was successful")

            logger.info(f"Deployment completed successfully on {server_name}")
            ssh_client.close()
            return True

        except Exception as e:
            logger.error(f"Deployment failed on {server_name}: {e}")
            return False

    def generate_docker_run_command(self, server_config: Dict[str, Any], validator_address: str = None) -> str:
        """Generate Docker run command for server"""
        image_name = self.config['docker']['image_name']
        image_tag = self.config['docker']['image_tag']
        registry = self.config['docker'].get('registry', '')

        if registry:
            full_image_name = f"{registry}/{image_name}:{image_tag}"
        else:
            full_image_name = f"{image_name}:{image_tag}"

        container_name = server_config['name']
        node_index = server_config['node_index']
        role = server_config['role']

        # Set environment variables
        env_vars = [
            f"-e NODE_TYPE={role}",
        ]

        # Generate port mappings
        ports = server_config['ports']
        port_mappings = [
            f"-p {ports['http']}:8545",      # HTTP port
            f"-p {ports['ws']}:8546",        # WebSocket port
            f"-p {ports['p2p']}:30303",      # P2P port
            f"-p {ports['metrics']}:6060",   # Metrics port
            f"-p 7060:6060"                  # PProf port (mapped to metrics port)
        ]

        # Generate volume mappings (match docker-entrypoint.sh paths)
        current_dir = Path(__file__).resolve().parent
        remote_base = f"{current_dir}/sipc2/{container_name}"

        # Basic volume mappings
        volume_mappings = [
            f"-v {remote_base}/keys:/home/sipc2/keys",
            f"-v {remote_base}/config/genesis.json:/home/sipc2/config/genesis.json",
            f"-v {remote_base}/config/config.toml:/home/sipc2/config/config.toml",
            f"-v {remote_base}/data:/data",
            # f"-v {remote_base}/keys/password.txt:/home/sipc2/password.txt"
        ]

        # Add keystore and bls mappings for validators
        if role == 'validator':
            # Add nodekey mapping
            nodekey_path = f"{remote_base}/keys/validator-nodekey"
            if os.path.exists(nodekey_path):
                volume_mappings.append(f"-v {nodekey_path}:/home/sipc2/keys/nodekey")

        elif role == 'sentry':
            # Add nodekey mapping for sentry
            nodekey_path = f"{remote_base}/keys/sentry-nodekey"
            if os.path.exists(nodekey_path):
                volume_mappings.append(f"-v {nodekey_path}:/home/sipc2/keys/nodekey")

        elif role == 'fullnode':
            # Add nodekey mapping for fullnode
            nodekey_path = f"{remote_base}/keys/fullnode-nodekey"
            if os.path.exists(nodekey_path):
                volume_mappings.append(f"-v {nodekey_path}:/home/sipc2/keys/nodekey")

        # Build Docker run command with native_start parameters
        if role == 'validator':
            # Use provided validator address or default
            if validator_address is None:
                validator_address = "0x0000000000000000000000000000000000000000"

            # Validator node startup command based on native_start
            docker_cmd = [
                "docker run -d",
                f"--name {container_name}",
                "--restart unless-stopped",
                " ".join(port_mappings),
                " ".join(volume_mappings),
                full_image_name,
                f"--mine --vote --password /home/sipc2/keys/password.txt --unlock {validator_address}",
                f"--miner.etherbase {validator_address} --blspassword /home/sipc2/keys/password.txt",
                "--nodekey /home/sipc2/keys/nodekey",
                "--blswallet /home/sipc2/keys/bls/wallet",
                "--keystore /home/sipc2/keys/validator/keystore",
                "--rpc.allow-unprotected-txs --allow-insecure-unlock",
                "--ws.addr 0.0.0.0 --ws.port 8546 --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain '*'",
                "--metrics --metrics.addr localhost --metrics.port 6060 --metrics.expensive",
                "--pprof --pprof.addr localhost --pprof.port 6060",
                "--gcmode archive --syncmode full --monitor.maliciousvote",
                "--override.passedforktime 1725500000 --override.lorentz 1725500000 --override.maxwell 1725500000",
                "--override.immutabilitythreshold 100 --override.breatheblockinterval 300",
                "--override.minforblobrequest 20 --override.defaultextrareserve 10"
            ]
        else:
            # Sentry/Full node startup command
            docker_cmd = [
                "docker run -d",
                f"--name {container_name}",
                "--restart unless-stopped",
                " ".join(port_mappings),
                " ".join(volume_mappings),
                full_image_name,
                "--rpc.allow-unprotected-txs --allow-insecure-unlock",
                "--ws.addr 0.0.0.0 --ws.port 8546 --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain '*'",
                "--metrics --metrics.addr localhost --metrics.port 6060 --metrics.expensive",
                "--pprof --pprof.addr localhost --pprof.port 6060",
                "--gcmode archive --syncmode full",
                "--override.passedforktime 1725500000 --override.lorentz 1725500000 --override.maxwell 1725500000",
                "--override.immutabilitythreshold 100 --override.breatheblockinterval 300",
                "--override.minforblobrequest 20 --override.defaultextrareserve 10"
            ]

        return " ".join(docker_cmd)

    def get_validator_address(self, node_index: int) -> str:
        """Get validator address from keystore file"""
        import os
        import json

        try:
            # Path to validator keystore directory
            current_dir = Path(__file__).resolve().parent
            validator_dir = os.path.join(current_dir, f"keys/validator{node_index}/keystore")

            if not os.path.exists(validator_dir):
                logger.error(f"Validator keystore directory not found: {validator_dir}")
                return "0x0000000000000000000000000000000000000000"

            # Find keystore file (should be the only file in the directory)
            keystore_files = [f for f in os.listdir(validator_dir)]
            if not keystore_files:
                logger.error(f"No keystore file found in {validator_dir}")
                return "0x0000000000000000000000000000000000000000"

            keystore_file = os.path.join(validator_dir, keystore_files[0])

            # Read and parse keystore file
            with open(keystore_file, 'r') as f:
                keystore_data = json.load(f)

            address = keystore_data.get('address', '')
            if address:
                # Ensure address has 0x prefix
                if not address.startswith('0x'):
                    address = f"0x{address}"
                logger.info(f"Found validator address for node {node_index}: {address}")
                return address
            else:
                logger.error(f"No address found in keystore file {keystore_file}")
                return "0x0000000000000000000000000000000000000000"

        except Exception as e:
            logger.error(f"Error reading validator address for node {node_index}: {e}")
            return "0x0000000000000000000000000000000000000000"

    def regenerate_genesis_and_configs(self) -> bool:
        """Regenerate genesis.json and config files if configured"""
        logger.info("Checking if genesis and config regeneration is needed...")

        regenerate_genesis = self.config['options'].get('regenerate_genesis', False)
        regenerate_configs = self.config['options'].get('regenerate_configs', False)

        if not regenerate_genesis and not regenerate_configs:
            logger.info("Genesis and config regeneration are both disabled, skipping...")
            return True

        try:
            if regenerate_genesis:
                logger.info("Regenerating genesis.json and base config...")

                # Call bsc_cluster.sh to regenerate genesis
                import subprocess
                script_path = "./bsc_cluster.sh"
            if not os.path.exists(script_path):
                print(f"ERROR: Script not found at {script_path}")
            else:
                result = subprocess.run(["bash", script_path, "regen-genesis"], 
                                    capture_output=True, 
                                    text=True, 
                                    cwd=".")
                
                print("Return code:", result.returncode)
                print("STDOUT:", result.stdout)
                if result.stderr:
                    print("STDERR:", result.stderr)
                #result = subprocess.run(["bash", "bsc_cluster.sh regen-genesis"], capture_output=True, text=True, cwd=".")
                if result.returncode != 0:
                    logger.error(f"Failed to regenerate genesis: {result.stderr}")
                    return False
                logger.info("Genesis and config regeneration completed successfully")

            if regenerate_configs:
                logger.info("Server-specific config regeneration will be handled during file distribution")

            return True

        except Exception as e:
            logger.error(f"Error during regeneration: {e}")
            return False

    def register_validator_stake(self, server_config: Dict[str, Any], ssh_client: paramiko.SSHClient, validator_address: str = None) -> bool:
        """Register validator and stake tokens after deployment"""
        server_name = server_config['name']
        node_index = server_config['node_index']
        ports = server_config['ports']

        # Get validator address if not provided
        if validator_address is None:
            validator_address = self.get_validator_address(node_index)

        logger.info(f"Registering validator {validator_address} and staking tokens for {server_name}")
        current_dir = Path(__file__).resolve().parent
        try:
            # Wait for node to be ready
            time.sleep(45)

            # Create staking command using native create-validator binary
            staking_command = f"""
# Execute validator registration using native binary
echo "Executing validator registration using native create-validator..."
echo "Validator address: {validator_address}"

{current_dir}/sipc2/{server_name}/create-validator \\
    --consensus-key-dir {current_dir}/sipc2/{server_name}/keys/validator \\
    --vote-key-dir {current_dir}/sipc2/{server_name}/keys \\
    --password-path {current_dir}/sipc2/{server_name}/keys/password.txt \\
    --amount 20001 \\
    --validator-desc Val{node_index} \\
    --rpc-url http://localhost:{ports['http']}

if [ $? -eq 0 ]; then
    echo "Validator registration completed successfully for {validator_address}"
else
    echo "Validator registration failed for {validator_address}, but node deployment was successful"
    echo "You may need to manually register the validator later"
    exit 1
fi
"""

            # Upload and execute staking script
            remote_script_path = f"{current_dir}/sipc2/{server_name}/register_stake.sh"
            with ssh_client.open_sftp() as sftp:
                with sftp.file(remote_script_path, 'w') as f:
                    f.write(staking_command)

            # Make script executable and run it
            stdin, stdout, stderr = ssh_client.exec_command(f"chmod +x {remote_script_path} && {remote_script_path}")
            print(stdout.read().decode())
            print(stderr.read().decode())
            exit_code = stdout.channel.recv_exit_status()

            if exit_code != 0:
                error = stderr.read().decode()
                logger.warning(f"Staking registration failed on {server_name}: {error}")
                logger.warning("This might be expected if create-validator tool is not available")
                return False

            logger.info(f"Staking registration completed successfully on {server_name}")
            return True

        except Exception as e:
            logger.error(f"Error during staking registration on {server_name}: {e}")
            return False

    def monitor_deployment(self) -> Dict[str, Any]:
        """Monitor deployment status"""
        logger.info("Monitoring deployment status...")

        status = {}
        servers = self.config['servers']

        for server in servers:
            server_name = server['name']
            status[server_name] = self.check_server_status(server)   

        return status

    def check_server_status(self, server_config: Dict[str, Any]) -> Dict[str, str]:
        """Check status of BSC node on server"""
        try:
            ssh_client = self.create_ssh_client(server_config)
            container_name = server_config['name']

            # Check if container is running
            stdin, stdout, stderr = ssh_client.exec_command(f"docker ps --filter name={container_name} --format '{{{{.Status}}}}'")
            status_output = stdout.read().decode().strip()

            if status_output:
                # Check container health
                stdin, stdout, stderr = ssh_client.exec_command(f"docker inspect {container_name} --format '{{{{.State.Health.Status}}}}'")
                health_output = stdout.read().decode().strip()

                return {
                    "status": "running",
                    "health": health_output if health_output else "unknown",
                    "details": status_output
                }
            else:
                return {
                    "status": "stopped",
                    "health": "n/a",
                    "details": "Container not running"
                }

        except Exception as e:
            return {
                "status": "error",
                "health": "n/a",
                "details": str(e)
            }

    def deploy_cluster(self) -> bool:
        """Deploy BSC cluster to all servers"""
        logger.info("Starting BSC cluster deployment")

        # Build Docker image
        if not self.config['options'].get('skip_build', False):
            if not self.build_docker_image():
                return False

            if not self.push_docker_image():
                return False

        # Regenerate genesis and configs if needed
        if not self.regenerate_genesis_and_configs():
            logger.error("Failed to regenerate genesis and configs")
            return False

        # Distribute files
        if not self.config['options'].get('skip_distribution', False):
            if not self.distributor.distribute_files(
                parallel=self.config['options'].get('parallel_deployment', True),
                max_parallel=self.config['options'].get('max_parallel', 5)
            ):
                return False

        # Deploy to servers
        servers = self.config['servers']
        parallel = self.config['options'].get('parallel_deployment', True)
        max_parallel = self.config['options'].get('max_parallel', 5)

        if parallel and len(servers) > 1:
            logger.info(f"Starting parallel deployment to {len(servers)} servers")

            with ThreadPoolExecutor(max_workers=max_parallel) as executor:
                futures = [
                    executor.submit(self.deploy_to_server, server)
                    for server in servers
                ]

                success_count = 0
                for future in as_completed(futures):
                    if future.result():
                        success_count += 1

                logger.info(f"Deployment completed: {success_count}/{len(servers)} successful")
                return success_count == len(servers)
        else:
            logger.info("Starting sequential deployment")

            success_count = 0
            for server in servers:
                if self.deploy_to_server(server):
                    success_count += 1

            logger.info(f"Deployment completed: {success_count}/{len(servers)} successful")
            return success_count == len(servers)


def main():
    parser = argparse.ArgumentParser(description="BSC Cluster Deployer")
    parser.add_argument("--config", default="deployment-config.yaml", help="Path to deployment config file")
    parser.add_argument("--action", choices=['deploy', 'monitor', 'files'], default='deploy', help="Action to perform")
    parser.add_argument("--skip-build", action="store_true", help="Skip Docker image build")
    parser.add_argument("--skip-distribution", action="store_true", help="Skip file distribution")
    parser.add_argument("--regenerate-genesis", action="store_true", help="Force regenerate genesis.json")
    parser.add_argument("--no-regenerate-genesis", action="store_true", help="Skip genesis.json regeneration")
    parser.add_argument("--regenerate-configs", action="store_true", help="Force regenerate server-specific configs")
    parser.add_argument("--no-regenerate-configs", action="store_true", help="Skip server-specific config regeneration")

    args = parser.parse_args()

    # Validate config file
    if not os.path.exists(args.config):
        logger.error(f"Configuration file not found: {args.config}")
        return 1

    try:
        deployer = BSCClusterDeployer(args.config)

        # Override config options with command line args
        if args.skip_build:
            deployer.config['options']['skip_build'] = True
        if args.skip_distribution:
            deployer.config['options']['skip_distribution'] = True

        # Handle genesis regeneration options
        if args.regenerate_genesis:
            deployer.config['options']['regenerate_genesis'] = True
        if args.no_regenerate_genesis:
            deployer.config['options']['regenerate_genesis'] = False

        # Handle config regeneration options
        if args.regenerate_configs:
            deployer.config['options']['regenerate_configs'] = True
        if args.no_regenerate_configs:
            deployer.config['options']['regenerate_configs'] = False

        if args.action == 'deploy':
            success = deployer.deploy_cluster()
        elif args.action == 'monitor':
            status = deployer.monitor_deployment()
            print(yaml.dump(status, default_flow_style=False))
            success = True
        elif args.action == 'files':
            success = deployer.distributor.distribute_files()

        return 0 if success else 1

    except Exception as e:
        logger.error(f"Deployment failed: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
