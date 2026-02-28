#!/bin/bash
set -e

# GH_TOKEN is automatically used by gh CLI if set in environment

# Set allowed origins for Control UI if not already configured
openclaw config set gateway.controlUi.allowedOrigins '["http://127.0.0.1:18789","http://localhost:18789"]' --strict-json 2>/dev/null || true

# Start the gateway
exec openclaw gateway --bind lan --port 18789 --allow-unconfigured
