#!/bin/bash
#
# OpenClaw Docker-in-Docker Startup Script
# Usage: ./start.sh [command]
#
# Commands:
#   start     - Build and start OpenClaw (default)
#   stop      - Stop all containers
#   logs      - Follow container logs
#   shell     - Open shell in container
#   onboard   - Run onboarding wizard
#   restart   - Restart OpenClaw gateway
#   status    - Show status
#   clean     - Remove everything (warning: deletes data)
#   help      - Show this help
#

set -e

COMPOSE_CMD="docker compose"
CONTAINER_NAME="openclaw-dind"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║   🦞 OpenClaw Docker-in-Docker      ║"
    echo "║   🔒 Fully Isolated (Internet Only) ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

cmd_start() {
    print_banner
    echo -e "${GREEN}Building and starting OpenClaw...${NC}"
    $COMPOSE_CMD up -d --build openclaw-dind
    echo ""
    echo -e "${GREEN}OpenClaw is starting!${NC}"
    echo ""
    echo "  Control UI: http://localhost:18789"
    echo ""
    echo "  Next steps:"
    echo "    ./start.sh onboard  - Run the setup wizard"
    echo "    ./start.sh logs     - Watch the logs"
    echo ""
}

cmd_stop() {
    echo -e "${YELLOW}Stopping OpenClaw...${NC}"
    $COMPOSE_CMD down
    echo -e "${GREEN}Stopped.${NC}"
}

cmd_info() {
    print_banner
    echo -e "${GREEN}Security Features:${NC}"
    echo "  ❌ NO host filesystem access"
    echo "  ❌ NO access to host Docker"
    echo "  ✅ Internet access only"
    echo "  ✅ All data in Docker volumes"
    echo ""
}

cmd_logs() {
    $COMPOSE_CMD logs -f openclaw-dind
}

cmd_shell() {
    echo -e "${BLUE}Opening shell in container...${NC}"
    docker exec -it $CONTAINER_NAME /bin/bash
}

cmd_onboard() {
    print_banner
    echo -e "${GREEN}Running onboarding wizard...${NC}"
    echo ""
    docker exec -it $CONTAINER_NAME su -c "openclaw onboard" node
}

cmd_restart() {
    echo -e "${YELLOW}Restarting OpenClaw gateway...${NC}"
    docker exec $CONTAINER_NAME supervisorctl restart openclaw-gateway
    echo -e "${GREEN}Restarted.${NC}"
}

cmd_status() {
    echo -e "${BLUE}=== Container Status ===${NC}"
    $COMPOSE_CMD ps
    echo ""
    echo -e "${BLUE}=== Inner Docker Status ===${NC}"
    docker exec $CONTAINER_NAME docker info 2>/dev/null || echo "Container not running"
}

cmd_clean() {
    echo -e "${RED}WARNING: This will remove all containers and volumes!${NC}"
    echo -e "${RED}All OpenClaw configuration and data will be lost.${NC}"
    read -p "Are you sure? [y/N] " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "Cleaning up..."
        $COMPOSE_CMD down -v
        docker volume rm -f openclaw-config openclaw-workspace openclaw-docker-data 2>/dev/null || true
        echo -e "${GREEN}Cleaned.${NC}"
    else
        echo "Cancelled."
    fi
}

cmd_help() {
    print_banner
    echo "Usage: ./start.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     Build and start OpenClaw (default)"
    echo "  stop      Stop all containers"
    echo "  logs      Follow container logs"
    echo "  shell     Open shell in container"
    echo "  onboard   Run onboarding wizard"
    echo "  restart   Restart OpenClaw gateway"
    echo "  status    Show status"
    echo "  clean     Remove everything (deletes data!)"
    echo "  help      Show this help"
    echo ""
    echo "Examples:"
    echo "  ./start.sh              # Start OpenClaw"
    echo "  ./start.sh onboard      # Run setup wizard"
    echo "  ./start.sh logs         # Watch logs"
    echo ""
}

# Main
case "${1:-start}" in
    start)    cmd_start ;;
    stop)     cmd_stop ;;
    logs)     cmd_logs ;;
    shell)    cmd_shell ;;
    onboard)  cmd_onboard ;;
    restart)  cmd_restart ;;
    status)   cmd_status ;;
    clean)    cmd_clean ;;
    help|-h|--help) cmd_help ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Run './start.sh help' for usage"
        exit 1
        ;;
esac
