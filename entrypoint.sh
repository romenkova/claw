#!/bin/bash
set -e

# GH_TOKEN is automatically used by gh CLI if set in environment

# Post-install: set up pnpm, install packages, build, and link globally
TOOLS_MONOREPO="/home/node/.openclaw/workspace/tools-monorepo"
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
