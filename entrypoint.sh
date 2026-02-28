#!/bin/bash
set -e

# Authenticate GitHub CLI if token is provided
if [ -n "$GH_TOKEN" ]; then
    echo "$GH_TOKEN" | gh auth login --with-token
    echo "GitHub CLI authenticated"
fi

# Set allowed origins for Control UI if not already configured
openclaw config set gateway.controlUi.allowedOrigins '["http://127.0.0.1:18789","http://localhost:18789"]' --strict-json 2>/dev/null || true

# Start the gateway
exec openclaw gateway --bind lan --port 18789 --allow-unconfigured
