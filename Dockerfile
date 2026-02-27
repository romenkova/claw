# OpenClaw Container
# SECURITY: No privileged mode, runs as non-root user

FROM node:22-bookworm

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    curl \
    bash \
    python3 \
    make \
    g++ \
    cmake \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set up directories
RUN mkdir -p /home/node/.openclaw/workspace && \
    chown -R node:node /home/node

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Copy and set up entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER node

# Expose OpenClaw port
EXPOSE 18789

# Working directory
WORKDIR /home/node

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -sf http://localhost:18789/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
