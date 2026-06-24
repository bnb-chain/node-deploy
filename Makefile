# Makefile for BSC Local Cluster

.PHONY: cluster-up cluster-down cluster-logs cluster-clean cluster-restart

# Default Image to use for bootstrapping
TOOLBOX_IMAGE ?= bsc-toolbox:latest
COMPOSE_FILE := docker-compose.cluster.yml

# Auto initialize and bring up the cluster
cluster-up: check-deps
	@echo "[Phase 1] Initializing blockchain data & configs using isolated Toolbox environment..."
	docker run --rm -v "$(CURDIR):/node_deploy" -w /node_deploy $(TOOLBOX_IMAGE) bash docker_cluster.sh prepare
	@echo ""
	@echo "[Phase 2] Data prepared! Starting BSC cluster via Docker Compose..."
	docker compose -f "$(COMPOSE_FILE)" up -d
	@echo "[Phase 3] Waiting for RPC... then Registering Validators"
	@bash docker_cluster.sh wait-rpc
	@docker run --network bsc_cluster_network --rm -v "$(CURDIR):/node_deploy" -w /node_deploy $(TOOLBOX_IMAGE) bash docker_cluster.sh register
	@echo "BSC Local Cluster successfully started in background! Run 'make cluster-logs' to view live logs."

# Safely stop and remove all containers
cluster-down:
	@echo "Stopping and removing all BSC containers..."
	if [ -f "$(COMPOSE_FILE)" ]; then docker compose -f "$(COMPOSE_FILE)" down; fi

# View real-time logs for all cluster nodes
cluster-logs:
	if [ -f "$(COMPOSE_FILE)" ]; then docker compose -f "$(COMPOSE_FILE)" logs -f; fi

# Completely wipe cluster data and auto-generated configs (DANGEROUS)
cluster-clean: cluster-down
	@echo "Wiping all local cluster data and temporary configurations (.local/, YAML, .env)..."
	rm -rf "$(CURDIR)/.local"
	rm -f "$(CURDIR)/.env.cluster" "$(COMPOSE_FILE)"
	@echo "Workspace is completely clean."

# Fast restart without wiping data or rebuilding config
cluster-restart: cluster-down
	@echo "Restarting all BSC containers with existing config (Phase 2 only)..."
	if [ -f "$(COMPOSE_FILE)" ]; then docker compose -f "$(COMPOSE_FILE)" up -d; fi
	@echo "BSC Local Cluster successfully restarted."

# Ensure host has curl for wait-rpc (Phase 3)
check-deps:
	@command -v curl >/dev/null 2>&1 || (echo "ERROR: 'curl' not found on host. It is required for Phase 3!" && exit 1)
