#!/usr/bin/env python3
"""
SIPC2 Node File Distributor
Distributes necessary files to remote servers for Docker deployment
"""

import os
import yaml
import re
from eth_keys import keys
import paramiko
import argparse
import shutil
import socket
import subprocess
from pathlib import Path
from typing import Dict, List, Any
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class FileDistributor:
    def __init__(self, config_path: str):
        self.config = self.load_config(config_path)
        self.ssh_clients = {}

    def is_localhost(self, host: str) -> bool:
        """Check if the target host is localhost"""
        localhost_addresses = ['localhost', '127.0.0.1', '::1']

        # Check direct matches
        if host.lower() in localhost_addresses:
            return True

        # Try to resolve hostname and check if it's localhost
        try:
            resolved_ip = socket.gethostbyname(host)
            if resolved_ip in ['127.0.0.1', '::1']:
                return True

            # Get local IP addresses
            local_ips = socket.gethostbyname_ex(socket.gethostname())[2]
            if resolved_ip in local_ips:
                return True

        except socket.gaierror:
            pass

        return False

    def generate_genesis_and_config(self):
        """Generate genesis.json and base config.toml before distribution"""
        logger.info("Checking if genesis generation is needed...")

        # Check if regeneration is enabled in config
        if not self.config['options'].get('regenerate_genesis', False):
            logger.info("Genesis regeneration is disabled, skipping...")
            return True

        logger.info("Generating genesis.json and config files...")

        try:
            # Call bsc_cluster.sh to generate genesis
            import subprocess
            result = subprocess.run(["bash", "bsc_cluster.sh"], capture_output=True, text=True)
            if result.returncode != 0:
                logger.error(f"Failed to generate genesis: {result.stderr}")
                return False

            logger.info("Genesis and config generation completed")
            return True

        except Exception as e:
            logger.error(f"Error generating genesis and config: {e}")
            return False

    def generate_server_config(self, server_config: Dict[str, Any]) -> str:
        """Generate server-specific config.toml"""
        # Read base config template
        config_template_path = self.config['files']['config']
        if not os.path.exists(config_template_path):
            logger.error(f"Config template not found: {config_template_path}")
            return None

        with open(config_template_path, 'r', encoding='utf-8') as f:
            config_content = f.read()

        # Update config with server-specific values using regex to be robust to template differences
        ports = server_config['ports']
        chain_id = self.config['deployment']['chain_id']

        # Replace NetworkId
        config_content = re.sub(r"(?m)^(\s*NetworkId\s*=\s*)\d+\b", rf"\g<1>{chain_id}", config_content)
        # Replace HTTPPort
        config_content = re.sub(r"(?m)^(\s*HTTPPort\s*=\s*)\d+\b", rf"\g<1>{ports['http']}", config_content)
        # Replace WSPort
        config_content = re.sub(r"(?m)^(\s*WSPort\s*=\s*)\d+\b", rf"\g<1>{ports['ws']}", config_content)

        # Compute and inject StaticNodes from all peers' nodekeys
        try:
            static_nodes: List[str] = []
            trusted_nodes: List[str] = []

            for peer in self.config['servers']:
                # Skip self
                if peer['name'] == server_config['name']:
                    continue

                peer_nodekey_path = self._resolve_nodekey_path(peer)
                if not peer_nodekey_path or not os.path.exists(peer_nodekey_path):
                    logger.warning(f"Nodekey not found for {peer['name']}: {peer_nodekey_path}")
                    continue

                enode_id_hex = self._derive_enode_id_from_nodekey(peer_nodekey_path)
                if not enode_id_hex:
                    logger.warning(f"Failed to derive enode for {peer['name']}")
                    continue

                # Prefer public_ip if provided
                peer_ip = peer.get('public_ip', peer['host'])
                peer_p2p = peer['ports']['p2p']
                enode_url = f"enode://{enode_id_hex}@{peer_ip}:{peer_p2p}"
                static_nodes.append(enode_url)
                trusted_nodes.append(enode_url)

            if static_nodes:
                static_nodes_literal = "[" + ", ".join([f'\"{u}\"' for u in static_nodes]) + "]"

                # Try to replace existing StaticNodes
                if re.search(r"(?m)^\s*StaticNodes\s*=\s*\[.*\]", config_content):
                    config_content = re.sub(
                        r"(?ms)^(\s*StaticNodes\s*=\s*)\[.*?\]",
                        rf"\g<1>{static_nodes_literal}",
                        config_content,
                    )
                else:
                    # Insert under [Node.P2P] section
                    if "[Node.P2P]" in config_content:
                        config_content = re.sub(
                            r"(?ms)(\[Node\.P2P\].*?)(\n\[|\Z)",
                            lambda m: m.group(1) + f"\nStaticNodes = {static_nodes_literal}\n" + m.group(2),
                            config_content,
                        )
                    else:
                        # Append at end as fallback
                        config_content += f"\n[Node.P2P]\nStaticNodes = {static_nodes_literal}\n"

            if trusted_nodes:
                trusted_nodes_literal = "[" + ", ".join([f'\"{u}\"' for u in trusted_nodes]) + "]"

                # Try to replace existing TrustedNodes
                if re.search(r"(?m)^\s*TrustedNodes\s*=\s*\[.*\]", config_content):
                    config_content = re.sub(
                        r"(?ms)^(\s*TrustedNodes\s*=\s*)\[.*?\]",
                        rf"\g<1>{trusted_nodes_literal}",
                        config_content,
                    )
                else:
                    # Insert under [Node.P2P] section
                    if "[Node.P2P]" in config_content:
                        config_content = re.sub(
                            r"(?ms)(\[Node\.P2P\].*?)(\n\[|\Z)",
                            lambda m: m.group(1) + f"\nTrustedNodes = {trusted_nodes_literal}\n" + m.group(2),
                            config_content,
                        )
                    else:
                        # Append at end as fallback
                        config_content += f"\n[Node.P2P]\nTrustedNodes = {trusted_nodes_literal}\n"
        except Exception as e:
            logger.error(f"Failed to inject StaticNodes: {e}")

        # Generate server-specific config file path
        server_name = server_config['name']
        server_config_path = f"config/config_{server_name}.toml"

        # Ensure config directory exists
        os.makedirs("config", exist_ok=True)

        # Write server-specific config
        with open(server_config_path, 'w', encoding='utf-8') as f:
            f.write(config_content)

        logger.info(f"Generated server config for {server_name}: {server_config_path}")
        return server_config_path

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
            private_key = None

            # Try to load Ed25519 key first
            try:
                private_key = paramiko.Ed25519Key.from_private_key_file(private_key_path)
                logger.debug(f"Loaded Ed25519 key from {private_key_path}")
            except Exception:
                # If Ed25519 fails, try RSA key
                try:
                    private_key = paramiko.RSAKey.from_private_key_file(private_key_path)
                    logger.debug(f"Loaded RSA key from {private_key_path}")
                except Exception as rsa_error:
                    logger.error(f"Failed to load SSH key from {private_key_path}: {rsa_error}")
                    raise ValueError(f"No valid SSH key found at {private_key_path}")

            if private_key is None:
                raise ValueError(f"Could not load SSH key from {private_key_path}")

            # Connect to server
            client.connect(
                hostname=server_config['host'],
                username=server_config['user'],
                pkey=private_key
            )

            logger.info(f"Connected to {server_config['name']} ({server_config['host']})")
            return client

        except Exception as e:
            logger.error(f"Failed to connect to {server_config['name']}: {e}")
            raise

    def ensure_remote_directory(self, ssh_client: paramiko.SSHClient, remote_path: str):
        """Ensure remote directory exists"""
        try:
            stdin, stdout, stderr = ssh_client.exec_command(f"mkdir -p {remote_path}")
            exit_code = stdout.channel.recv_exit_status()

            if exit_code != 0:
                error = stderr.read().decode()
                logger.error(f"Failed to create directory {remote_path}: {error}")
                return False

            return True
        except Exception as e:
            logger.error(f"Error creating directory {remote_path}: {e}")
            return False

    def copy_file_local(self, local_path: str, remote_path: str) -> bool:
        """Copy file locally (for localhost deployments)"""
        try:
            # Ensure destination directory exists
            remote_dir = os.path.dirname(remote_path)
            os.makedirs(remote_dir, exist_ok=True)

            # Copy file
            shutil.copy2(local_path, remote_path)
            logger.info(f"Copied {local_path} -> {remote_path}")
            return True

        except Exception as e:
            logger.error(f"Failed to copy {local_path} to {remote_path}: {e}")
            return False

    def upload_file(self, ssh_client: paramiko.SSHClient, local_path: str, remote_path: str, host: str = None) -> bool:
        """Upload file to remote server or copy locally for localhost"""
        try:
            # Check if target is localhost
            if host and self.is_localhost(host):
                return self.copy_file_local(local_path, remote_path)

            # Create SFTP client for remote hosts
            sftp = ssh_client.open_sftp()

            # Upload file
            sftp.put(local_path, remote_path)

            sftp.close()
            logger.info(f"Uploaded {local_path} -> {remote_path}")
            return True

        except Exception as e:
            logger.error(f"Failed to upload {local_path} to {remote_path}: {e}")
            return False

    def copy_directory_local(self, local_dir: str, remote_dir: str) -> bool:
        """Copy directory locally (for localhost deployments)"""
        try:
            # Use shutil.copytree to copy entire directory
            if os.path.exists(remote_dir):
                shutil.rmtree(remote_dir)
            shutil.copytree(local_dir, remote_dir)
            logger.info(f"Copied directory {local_dir} -> {remote_dir}")
            return True

        except Exception as e:
            logger.error(f"Failed to copy directory {local_dir} to {remote_dir}: {e}")
            return False

    def upload_directory(self, ssh_client: paramiko.SSHClient, local_dir: str, remote_dir: str, host: str = None) -> bool:
        """Upload directory recursively to remote server or copy locally for localhost"""
        try:
            # Check if target is localhost
            if host and self.is_localhost(host):
                return self.copy_directory_local(local_dir, remote_dir)

            # Create SFTP client for remote hosts
            sftp = ssh_client.open_sftp()

            # Walk through local directory
            for root, dirs, files in os.walk(local_dir):
                # Calculate relative path
                relative_path = os.path.relpath(root, local_dir)
                if relative_path == '.':
                    remote_path = remote_dir
                else:
                    remote_path = os.path.join(remote_dir, relative_path)

                # Create remote directory
                try:
                    sftp.mkdir(remote_path)
                except IOError:
                    pass  # Directory might already exist

                # Upload files
                for file in files:
                    local_file = os.path.join(root, file)
                    remote_file = os.path.join(remote_path, file)
                    sftp.put(local_file, remote_file)
                    logger.info(f"Uploaded {local_file} -> {remote_file}")

            sftp.close()
            logger.info(f"Uploaded directory {local_dir} -> {remote_dir}")
            return True

        except Exception as e:
            logger.error(f"Failed to upload directory {local_dir} to {remote_dir}: {e}")
            return False

    def distribute_files_to_server(self, server_config: Dict[str, Any]) -> bool:
        """Distribute files to a specific server"""
        server_name = server_config['name']
        server_host = server_config['host']
        logger.info(f"Starting file distribution to {server_name}")
        current_dir = Path(__file__).resolve().parent

        # Check if this is localhost deployment
        is_local = self.is_localhost(server_host)
        if is_local:
            logger.info(f"Detected localhost deployment for {server_name}, will use local file copy")
        else:
            logger.info(f"Remote deployment to {server_name} ({server_host})")

        try:
            # For localhost, we don't need SSH client
            if is_local:
                ssh_client = None
            else:
                # Create SSH client for remote hosts
                ssh_client = self.create_ssh_client(server_config)

            # Create remote directories (use user home directory instead of /opt)
            if is_local:
                remote_base = os.path.join(current_dir, "sipc2", server_name)
                os.makedirs(remote_base, exist_ok=True)
                os.makedirs(os.path.join(remote_base, "config"), exist_ok=True)
                os.makedirs(os.path.join(remote_base, "keys"), exist_ok=True)
                os.makedirs(os.path.join(remote_base, "data"), exist_ok=True)
            else:
                remote_base = f"{current_dir}/sipc2/{server_name}"
                if ssh_client:
                    self.ensure_remote_directory(ssh_client, remote_base)
                    self.ensure_remote_directory(ssh_client, f"{remote_base}/config")
                    self.ensure_remote_directory(ssh_client, f"{remote_base}/keys")
                    self.ensure_remote_directory(ssh_client, f"{remote_base}/data")
                else:
                    logger.error("SSH client is not available for remote directory creation")
                    return False

            # Compile create-validator if binary doesn't exist
            create_validator_path = os.path.join(current_dir, "create-validator/create-validator")
            create_validator_dir = os.path.join(current_dir, "create-validator")

            if not os.path.exists(create_validator_path):
                logger.info("create-validator binary not found, compiling from Go source...")
                try:
                    # Check if Go is installed
                    subprocess.run(["go", "version"], check=True, capture_output=True)

                    # Change to create-validator directory and build
                    os.chdir(create_validator_dir)
                    result = subprocess.run(["go", "build", "-o", "create-validator", "main.go"],
                                          capture_output=True, text=True)

                    if result.returncode == 0:
                        logger.info("Successfully compiled create-validator")
                    else:
                        logger.error(f"Failed to compile create-validator: {result.stderr}")
                        logger.warning("Continuing without create-validator binary")

                except subprocess.CalledProcessError as e:
                    logger.error(f"Go is not installed or not accessible: {e}")
                    logger.warning("Continuing without create-validator binary")
                except FileNotFoundError:
                    logger.error("Go compiler not found")
                    logger.warning("Continuing without create-validator binary")
                except Exception as e:
                    logger.error(f"Error compiling create-validator: {e}")
                    logger.warning("Continuing without create-validator binary")
                finally:
                    # Ensure we're back in the original directory
                    os.chdir(current_dir)

            # Upload create-validator binary for staking
            if os.path.exists(create_validator_path):
                logger.info(f"Uploading create-validator binary to {server_name}")
                remote_create_validator_path = os.path.join(remote_base, "create-validator") if is_local else f"{remote_base}/create-validator"
                if is_local:
                    self.upload_file(None, create_validator_path, remote_create_validator_path, server_host)
                    # Make executable
                    os.chmod(remote_create_validator_path, 0o755)
                else:
                    self.upload_file(ssh_client, create_validator_path, f"{remote_base}/create-validator", server_host)
                    # Make executable
                    ssh_client.exec_command(f"chmod +x {remote_base}/create-validator")
            else:
                logger.warning("create-validator binary is not available for upload")

            # Upload genesis file
            genesis_path = os.path.join(current_dir, self.config['files']['genesis'])
            if os.path.exists(genesis_path):
                remote_genesis_path = os.path.join(remote_base, "config", "genesis.json") if is_local else f"{remote_base}/config/genesis.json"
                if is_local:
                    self.upload_file(None, genesis_path, remote_genesis_path, server_host)
                else:
                    self.upload_file(ssh_client, genesis_path, f"{remote_base}/config/genesis.json", server_host)

            # Generate and upload server-specific config file
            if self.config['options'].get('regenerate_configs', True):
                server_config_path = os.path.join(current_dir, self.generate_server_config(server_config))
                if server_config_path and os.path.exists(server_config_path):
                    remote_config_path = os.path.join(remote_base, "config", "config.toml") if is_local else f"{remote_base}/config/config.toml"
                    if is_local:
                        self.upload_file(None, server_config_path, remote_config_path, server_host)
                    else:
                        self.upload_file(ssh_client, server_config_path, f"{remote_base}/config/config.toml", server_host)
            else:
                # Use the default config.toml if regeneration is disabled
                config_path = os.path.join(current_dir, self.config['files']['config'])
                if os.path.exists(config_path):
                    remote_config_path = os.path.join(remote_base, "config", "config.toml") if is_local else f"{remote_base}/config/config.toml"
                    if is_local:
                        self.upload_file(None, config_path, remote_config_path, server_host)
                    else:
                        self.upload_file(ssh_client, config_path, f"{remote_base}/config/config.toml", server_host)

            # Upload keys based on node type and index
            node_index = server_config['node_index']
            role = server_config['role']

            if role == 'validator':
                # Upload validator keys
                validator_key_dir = os.path.join(current_dir, f"{self.config['files']['keys_base']}/validator{node_index}")
                if os.path.exists(validator_key_dir):
                    remote_validator_path = os.path.join(remote_base, "keys", "validator") if is_local else f"{remote_base}/keys/validator"
                    if is_local:
                        # For local, remove directory if it exists
                        if os.path.exists(remote_validator_path) and os.path.isdir(remote_validator_path):
                            import shutil
                            shutil.rmtree(remote_validator_path)
                            if os.path.isdir(validator_key_dir):
                                self.upload_directory(None, validator_key_dir, remote_validator_path, server_host)
                            else:
                                self.upload_file(None, validator_key_dir, remote_validator_path, server_host)
                    else:
                        # For remote, remove directory if it exists
                        if ssh_client:
                            ssh_client.exec_command(f"rm -rf {remote_base}/keys/validator")
                            if os.path.isdir(validator_key_dir):
                                self.upload_directory(ssh_client, validator_key_dir, f"{remote_base}/keys/validator", server_host)
                            else:
                                self.upload_file(ssh_client, validator_key_dir, f"{remote_base}/keys/validator", server_host)

                # Upload consensus keys
                consensus_key_dir = os.path.join(current_dir, f"{self.config['files']['keys_base']}/consensus{node_index}")
                if os.path.exists(consensus_key_dir):
                    remote_consensus_path = os.path.join(remote_base, "keys", "consensus") if is_local else f"{remote_base}/keys/consensus"
                    if is_local:
                        # For local, remove directory if it exists
                        if os.path.exists(remote_consensus_path) and os.path.isdir(remote_consensus_path):
                            import shutil
                            shutil.rmtree(remote_consensus_path)
                        self.upload_directory(None, consensus_key_dir, remote_consensus_path, server_host)
                    else:
                        if ssh_client:
                            ssh_client.exec_command(f"rm -rf {remote_base}/keys/consensus")
                        self.upload_directory(ssh_client, consensus_key_dir, f"{remote_base}/keys/consensus", server_host)
                
                # Upload BLS keys
                bls_key_dir = os.path.join(current_dir, f"{self.config['files']['keys_base']}/bls{node_index}")
                if os.path.exists(bls_key_dir):
                    remote_bls_path = os.path.join(remote_base, "keys/bls") if is_local else f"{remote_base}/keys/bls"
                    if is_local:
                        # For local, remove directory if it exists
                        if os.path.exists(remote_bls_path) and os.path.isdir(remote_bls_path):
                            import shutil
                            shutil.rmtree(remote_bls_path)
                        self.upload_directory(None, bls_key_dir, f"{remote_base}/keys/", server_host)
                    else:
                        # For remote, remove directory if it exists
                        if ssh_client:
                            ssh_client.exec_command(f"rm -rf {remote_base}/keys/bls")
                        self.upload_directory(ssh_client, bls_key_dir, f"{remote_base}/keys/", server_host)

                # Upload validator nodekey
                validator_nodekey_file = os.path.join(current_dir, f"{self.config['files']['keys_base']}/validator-nodekey{node_index}")
                if os.path.exists(validator_nodekey_file):
                    remote_nodekey_path = os.path.join(remote_base, "keys", "validator-nodekey") if is_local else f"{remote_base}/keys/validator-nodekey"
                    if is_local:
                        self.upload_file(None, validator_nodekey_file, remote_nodekey_path, server_host)
                    else:
                        self.upload_file(ssh_client, validator_nodekey_file, f"{remote_base}/keys/validator-nodekey", server_host)

                # Upload password file
                password_file = os.path.join(current_dir, f"{self.config['files']['keys_base']}/password.txt")
                if os.path.exists(password_file):
                    if is_local:
                        self.upload_file(None, password_file, os.path.join(remote_base, "keys", "password.txt"), server_host)
                    else:
                        self.upload_file(ssh_client, password_file, f"{remote_base}/keys/password.txt", server_host)

            elif role in ['sentry', 'fullnode']:
                # Upload node key
                node_key_file = os.path.join(current_dir, f"{self.config['files']['keys_base']}/{role}-nodekey{node_index}")
                if os.path.exists(node_key_file):
                    if is_local:
                        self.upload_file(None, node_key_file, os.path.join(remote_base, "keys", f"{role}-nodekey"), server_host)
                    else:
                        self.upload_file(ssh_client, node_key_file, f"{remote_base}/keys/{role}-nodekey", server_host)

            # Upload password file for all node types
            password_file = os.path.join(current_dir, f"{self.config['files']['keys_base']}/password.txt")
            if os.path.exists(password_file):
                if is_local:
                    self.upload_file(None, password_file, os.path.join(remote_base, "keys", "password.txt"), server_host)
                else:
                    self.upload_file(ssh_client, password_file, f"{remote_base}/keys/password.txt", server_host)

            if not is_local and ssh_client:
                ssh_client.close()
            logger.info(f"File distribution completed for {server_name}")
            return True

        except Exception as e:
            logger.error(f"File distribution failed for {server_name}: {e}")
            return False

    def _resolve_nodekey_path(self, server: Dict[str, Any]) -> str:
        """Resolve local nodekey path for a server based on role and node_index"""
        current_dir = Path(__file__).resolve().parent
        keys_base = self.config['files']['keys_base']
        node_index = server['node_index']
        role = server['role']

        if role == 'validator':
            filename = f"validator-nodekey{node_index}"
        elif role == 'sentry':
            filename = f"sentry-nodekey{node_index}"
        elif role == 'fullnode':
            filename = f"fullnode-nodekey{node_index}"
        else:
            return None

        return os.path.join(current_dir, f"{keys_base}/{filename}")

    def _derive_enode_id_from_nodekey(self, nodekey_path: str) -> str:
        """Derive enode ID (pubkey hex without 0x) from a devp2p nodekey file"""
        try:
            with open(nodekey_path, 'rb') as f:
                key_bytes = f.read().strip()

            # Nodekey may be hex string or raw 32 bytes
            if len(key_bytes) > 32:
                try:
                    key_hex = key_bytes.decode().strip()
                    if key_hex.startswith('0x'):
                        key_hex = key_hex[2:]
                    key_bytes = bytes.fromhex(key_hex)
                except Exception:
                    # Assume it's text but not hex; raise
                    pass

            if len(key_bytes) != 32:
                raise ValueError("Invalid nodekey length; expected 32 bytes")

            priv = keys.PrivateKey(key_bytes)
            pub_bytes = priv.public_key.to_bytes()  # 64 bytes (X||Y)
            return pub_bytes.hex()
        except Exception as e:
            logger.error(f"Failed to derive enode from {nodekey_path}: {e}")
            return None

    def distribute_files(self, parallel: bool = True, max_parallel: int = 5) -> bool:
        """Distribute files to all servers in the cluster"""

        # Generate genesis and base config before distribution
        if not self.generate_genesis_and_config():
            logger.error("Failed to generate genesis and config files")
            return False

        servers = self.config['servers']

        if parallel and len(servers) > 1:
            logger.info(f"Starting parallel file distribution to {len(servers)} servers")

            with ThreadPoolExecutor(max_workers=max_parallel) as executor:
                futures = [
                    executor.submit(self.distribute_files_to_server, server)
                    for server in servers
                ]

                success_count = 0
                for future in as_completed(futures):
                    if future.result():
                        success_count += 1

                logger.info(f"File distribution completed: {success_count}/{len(servers)} successful")
                return success_count == len(servers)
        else:
            logger.info("Starting sequential file distribution")

            success_count = 0
            for server in servers:
                if self.distribute_files_to_server(server):
                    success_count += 1

            logger.info(f"File distribution completed: {success_count}/{len(servers)} successful")
            return success_count == len(servers)


def main():
    parser = argparse.ArgumentParser(description="BSC Node File Distributor")
    parser.add_argument("--config", default="deployment-config.yaml", help="Path to deployment config file")
    parser.add_argument("--parallel", action="store_true", help="Enable parallel distribution")
    parser.add_argument("--max-parallel", type=int, default=5, help="Maximum parallel workers")
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
        distributor = FileDistributor(args.config)

        # Override config options with command line args
        if args.regenerate_genesis:
            distributor.config['options']['regenerate_genesis'] = True
        if args.no_regenerate_genesis:
            distributor.config['options']['regenerate_genesis'] = False
        if args.regenerate_configs:
            distributor.config['options']['regenerate_configs'] = True
        if args.no_regenerate_configs:
            distributor.config['options']['regenerate_configs'] = False

        success = distributor.distribute_files(
            parallel=args.parallel,
            max_parallel=args.max_parallel
        )

        return 0 if success else 1

    except Exception as e:
        logger.error(f"File distribution failed: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
