# BSC Node Docker Image
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    jq \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash sipc2

# Set working directory
WORKDIR /home/sipc2

# Copy sipc2 binary and configuration
COPY bin/geth /usr/local/bin/geth
RUN chmod +x /usr/local/bin/geth

# Copy scripts
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create data directory
RUN mkdir -p /home/sipc2/data

# Set ownership
RUN chown -R sipc2:sipc2 /home/sipc2

# Switch to sipc2 user
USER sipc2

# Expose ports
EXPOSE 8545 8546 30303

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8545 || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
