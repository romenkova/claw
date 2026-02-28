#!/bin/bash
set -e

# GH_TOKEN is automatically used by gh CLI if set in environment

# Clone workspace repository if not already cloned
WORKSPACE_DIR="/home/node/.openclaw/workspace"
TOOLS_MONOREPO="$WORKSPACE_DIR/tools-monorepo"

if [ ! -d "$WORKSPACE_DIR/.git" ]; then
    echo "Cloning workspace repository..."
    git clone https://github.com/romenkova/claw-server.git "$WORKSPACE_DIR" || git clone https://github.com/romenkova/claw-server.git "$WORKSPACE_DIR" --depth 1
    echo "Workspace repository cloned."
else
    echo "Pulling latest changes..."
    cd "$WORKSPACE_DIR"
    git pull
    echo "Workspace repository updated."
fi

# Post-install: set up pnpm, install packages, build, and link globally
if [ -d "$TOOLS_MONOREPO" ]; then
    echo "Setting up tools-monorepo..."
    export PNPM_HOME="/home/node/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    cd "$TOOLS_MONOREPO"
    pnpm install
    pnpm build
    cd apps/cli
    pnpm link --global
    echo "tools-monorepo setup complete."
fi

# Set allowed origins for Control UI if not already configured
openclaw config set gateway.controlUi.allowedOrigins '["http://127.0.0.1:18789","http://localhost:18789"]' --strict-json 2>/dev/null || true

# Start the gateway
exec openclaw gateway --bind lan --port 18789 --allow-unconfigured
