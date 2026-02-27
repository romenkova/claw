.PHONY: build up down logs shell onboard status restart clean help

# Default target
help:
	@echo ""
	@echo "OpenClaw Docker (Secure & Isolated)"
	@echo "===================================="
	@echo ""
	@echo "SECURITY: Zero host access, no privileged mode"
	@echo ""
	@echo "Quick Start:"
	@echo "  make build    - Build the Docker image"
	@echo "  make up       - Start OpenClaw (detached)"
	@echo "  make onboard  - Run the onboarding wizard"
	@echo ""
	@echo "Management:"
	@echo "  make down     - Stop all containers"
	@echo "  make restart  - Restart the gateway"
	@echo "  make logs     - Follow container logs"
	@echo "  make status   - Show container status"
	@echo "  make shell    - Open a shell in the container"
	@echo ""
	@echo "Advanced:"
	@echo "  make clean    - Remove containers and volumes"
	@echo ""

# Build the Docker image
build:
	docker compose build

# Start OpenClaw in detached mode
up: build
	docker compose up -d
	@echo ""
	@echo "OpenClaw is starting..."
	@echo "Control UI: http://localhost:18789"
	@echo ""
	@echo "Run 'make onboard' to set up OpenClaw"
	@echo "Run 'make logs' to follow the logs"

# Stop all containers
down:
	docker compose down

# View logs
logs:
	docker compose logs -f openclaw

# Open shell in container
shell:
	docker exec -it openclaw /bin/sh

# Run onboarding wizard
onboard:
	docker exec -it openclaw openclaw onboard

# Show status
status:
	@echo "=== Container Status ==="
	@docker compose ps

# Restart OpenClaw gateway
restart:
	docker compose restart openclaw

# Clean up everything (removes data!)
clean:
	@echo "WARNING: This will remove all containers and volumes!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	docker compose down -v
	docker volume rm -f openclaw-config openclaw-workspace 2>/dev/null || true

# Generate a gateway token
token:
	docker exec -it openclaw openclaw config get gateway.token

# Open dashboard
dashboard:
	docker exec -it openclaw openclaw dashboard --no-open

# Run CLI commands
cli:
	@echo "Usage: make cli CMD='<command>'"
	@echo "Example: make cli CMD='agent --message \"Hello\"'"
ifdef CMD
	docker exec -it openclaw openclaw $(CMD)
endif
