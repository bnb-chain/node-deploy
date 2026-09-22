#!/bin/bash
set -e

# Change to the application directory
cd /node_deploy

# Create a lock file to indicate initialization is in progress
touch /tmp/cluster_initializing

# If the container is starting for the first time or if we want to ensure
# a fresh start, we run the reset script.
echo "===================================================="
echo "Initializing BSC cluster... Please wait."
echo "use docker logs -f bsc-toolbox check for progress"
echo "===================================================="
bash ./bsc_cluster.sh reset

# Remove the lock file and signal completion
rm /tmp/cluster_initializing
echo ""
echo "===================================================="
echo ">>> BSC CLUSTER INITIALIZATION COMPLETE! <<<"
echo "===================================================="
echo ""

# Execute the passed command (e.g., /bin/bash)
exec "$@"
