# OpenClaw Docker Setup (Secure & Isolated)

Run [OpenClaw](https://github.com/openclaw/openclaw) personal AI assistant inside Docker with full isolation from your host system.

## Security

**This container has ZERO access to your host system:**

- NO host filesystem access
- NO access to host Docker
- NO privileged mode
- NO root user
- NO Linux capabilities
- Internet access only
- All data in isolated Docker volumes

### Security Hardening

| Protection | Status |
|------------|--------|
| Non-root user | Runs as `node` |
| `no-new-privileges` | Enabled |
| `cap_drop: ALL` | All capabilities dropped |
| Localhost-only port | `127.0.0.1:18789` |
| Isolated network | Bridge network |
| No host mounts | Docker volumes only |

## Quick Start

### 1. Build and Start

```bash
make up

# Or without make:
docker compose up -d --build
```

### 2. Run Onboarding

```bash
make onboard

# Or manually:
docker exec -it openclaw openclaw onboard
```

### 3. Access the Control UI

Open http://localhost:18789 in your browser.

## Available Commands

| Command | Description |
|---------|-------------|
| `make up` | Build and start OpenClaw |
| `make down` | Stop all containers |
| `make logs` | Follow container logs |
| `make shell` | Open a bash shell in the container |
| `make onboard` | Run the onboarding wizard |
| `make restart` | Restart the OpenClaw gateway |
| `make status` | Show container and Docker status |
| `make clean` | Remove all containers and volumes |

## Using OpenClaw CLI

```bash
docker exec -it openclaw openclaw agent --message 'Hello!'
docker exec -it openclaw openclaw doctor
docker exec -it openclaw openclaw channels list
```

## Ports

| Port | Service |
|------|---------|
| 18789 | OpenClaw Gateway (localhost only) |

## Volumes (Isolated - No Host Access)

| Volume | Purpose |
|--------|---------|
| `openclaw-config` | OpenClaw configuration |
| `openclaw-workspace` | Workspace files |

## Architecture

```
┌─────────────────────────────────────────┐
│              Host System                │
│                                         │
│   [Your Files]  ─── BLOCKED             │
│   [Host Docker] ─── BLOCKED             │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │     openclaw (isolated)           │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │   OpenClaw Gateway (:18789) │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │   Chromium (Puppeteer)      │  │  │
│  │  └─────────────────────────────┘  │  │
│  │               │                   │  │
│  │         [Internet] ✓              │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## License

MIT - See [OpenClaw License](https://github.com/openclaw/openclaw/blob/main/LICENSE)
