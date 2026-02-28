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

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set up directories
RUN mkdir -p /home/node/.openclaw/workspace && \
    chown -R node:node /home/node

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Post-install: set up pnpm, install packages, build, and link globally
RUN cd ~/.openclaw/workspace/tools-monorepo && \
    export PNPM_HOME="/home/node/.local/share/pnpm" && \
    export PATH="$PNPM_HOME:$PATH" && \
    pnpm install && \
    pnpm build && \
    cd apps/cli && \
    pnpm link --global

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
