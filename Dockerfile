# OpenClaw Container
# SECURITY: No privileged mode, no Docker-in-Docker
# Runs as non-root user

FROM node:22-alpine

# Install dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    curl \
    bash \
    supervisor \
    shadow \
    python3 \
    make \
    g++ \
    cmake \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Install pnpm
RUN npm install -g pnpm

# Set up directories
RUN mkdir -p /home/node/.openclaw/workspace && \
    chown -R node:node /home/node

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Switch to non-root user
USER node

# Expose OpenClaw port
EXPOSE 18789

# Working directory
WORKDIR /home/node

# Environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:18789/health || exit 1

CMD ["openclaw", "gateway", "--port", "18789"]
