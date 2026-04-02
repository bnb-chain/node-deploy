# Makefile for BSC Local Cluster

.PHONY: cluster-up cluster-down cluster-logs cluster-clean cluster-restart

# Default Image to use for bootstrapping
TOOLBOX_IMAGE ?= bsc-toolbox:latest

# Auto initialize and bring up the cluster
cluster-up:
	@echo "[Phase 1] Initializing blockchain data & configs using isolated Toolbox environment..."
	docker run --rm -v "$(PWD):/node_deploy" -w /node_deploy $(TOOLBOX_IMAGE) bash docker_cluster.sh prepare
	@echo ""
	@echo "[Phase 2] Data prepared! Starting BSC cluster via Docker Compose..."
	docker compose -f docker-compose.cluster.yml up -d
	@echo "BSC Local Cluster successfully started in background! Run 'make cluster-logs' to view live logs."

# Safely stop and remove all containers
cluster-down:
	@echo "Stopping and removing all BSC containers..."
	if [ -f docker-compose.cluster.yml ]; then docker compose -f docker-compose.cluster.yml down; fi

# View real-time logs for all cluster nodes
cluster-logs:
	if [ -f docker-compose.cluster.yml ]; then docker compose -f docker-compose.cluster.yml logs -f; fi

# Completely wipe cluster data and auto-generated configs (DANGEROUS)
cluster-clean: cluster-down
	@echo "Wiping all local cluster data and temporary configurations (.local/, YAML, .env)..."
	rm -rf .local
	rm -f .env.cluster docker-compose.cluster.yml
	@echo "Workspace is completely clean."

# Fast restart without wiping data or rebuilding config
cluster-restart: cluster-down
	@echo "Restarting all BSC containers with existing config (Phase 2 only)..."
	if [ -f docker-compose.cluster.yml ]; then docker compose -f docker-compose.cluster.yml up -d; fi
	@echo "BSC Local Cluster successfully restarted."
