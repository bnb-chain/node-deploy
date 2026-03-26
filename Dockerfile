# Multi-stage Dockerfile for BSC Node
# Stage 1: Build Environment with all required tools
# Using Bookworm as base for newer package support
FROM golang:1.24-bookworm AS build-env

# Arguments for versions
ARG NODE_VERSION=16.x

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

# Install Python 3.12 and Poetry
# Since Bookworm (Debian 12) has 3.11, we add the fast track or just use a python base
# To strictly match 3.12.x, we'll use the official python image logic or deadsnakes-like approach
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to 3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install Poetry using its official installer
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# Install Foundry (Ethereum development toolkit)
# This is needed because BSC's system contracts (in the genesis/ folder) use 'forge' to compile.
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /root/.foundry/bin/foundryup
ENV PATH="/root/.foundry/bin:$PATH"

WORKDIR /app

# Copy necessary files for tool verification
COPY requirements.txt .
# Note: Poetry installation of dependencies usually happens here if we have pyproject.toml

# Tool verification command
RUN go version && \
    node -v && \
    npm -v && \
    python3 --version && \
    poetry --version && \
    forge --version && \
    jq --version
