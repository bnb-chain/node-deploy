# Multi-stage Dockerfile for BSC Node
# Stage 1: Build Environment with all required tools
# We use Python 3.12 as the base to fulfill the requirement, then add Go 1.24
FROM python:3.12-bookworm AS build-env

# Arguments for versions
ARG NODE_VERSION=16.x
ARG GO_VERSION=1.24.0

# Install Go 1.24 (Detect architecture to support both x86_64 and arm64)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then GO_ARCH="amd64"; else GO_ARCH="arm64"; fi && \
    curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:$PATH"

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    jq \
    build-essential \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (README mentions v16.15.0)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@6.14.6

# Install Poetry using its official installer
# (Python 3.12 is already the system default in this image)
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# Install Foundry (Ethereum development toolkit)
# This is needed because BSC's system contracts (in the genesis/ folder) use 'forge' to compile.
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /root/.foundry/bin/foundryup
ENV PATH="/root/.foundry/bin:$PATH"

# Setting up the workspace
WORKDIR /node_deploy

# Copy and install Python requirements
# This avoids installing them manually every time you restart the container.
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Tool verification command
# This ensures that when the image is built, all required tools are present and functional.
RUN go version && \
    node -v && \
    npm -v && \
    python3 --version && \
    poetry --version && \
    forge --version && \
    jq --version

# Default command: show help or just stay open
CMD ["bash"]
