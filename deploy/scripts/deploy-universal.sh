#!/usr/bin/env bash
set -euo pipefail

# ===========================================================
#  Cyber Claw AI Deployer
#  Deploy em qualquer VPS, GitHub, Railway, Fly.io, Docker
#  Uso: ./deploy/scripts/deploy-universal.sh [target]
# ===========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
PINK='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${PINK}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     OPENCLAW UNIVERSAL DEPLOYER      ║"
echo "  ║     🚀 Cyberpunk Deployment Suite    ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

show_help() {
  echo "Usage: ./deploy/scripts/deploy-universal.sh [option]"
  echo ""
  echo "Options:"
  echo "  github       Deploy via GitHub Actions (CI/CD)"
  echo "  vps          Deploy to a VPS (SSH)"
  echo "  railway      Deploy to Railway"
  echo "  fly          Deploy to Fly.io"
  echo "  docker       Deploy via Docker Compose"
  echo "  all          Deploy to all configured targets"
  echo "  help         Show this help"
}

case "${1:-help}" in
  github)
    echo -e "${CYAN}▶ Deploying via GitHub Actions...${NC}"
    if [ -d .git ]; then
      git push origin main
      echo -e "${GREEN}✔ Code pushed. GitHub Actions will handle the rest.${NC}"
    else
      echo -e "${RED}✘ Not a git repository. Run 'git init' first.${NC}"
    fi
    ;;

  vps)
    VPS_HOST="${DEPLOY_VPS_HOST:-}"
    VPS_USER="${DEPLOY_VPS_USER:-root}"
    VPS_PATH="${DEPLOY_VPS_PATH:-/opt/openclaw}"

    if [ -z "$VPS_HOST" ]; then
      echo -e "${RED}✘ Set DEPLOY_VPS_HOST environment variable.${NC}"
      echo "  export DEPLOY_VPS_HOST=your.vps.ip"
      exit 1
    fi

    echo -e "${CYAN}▶ Deploying to VPS: ${VPS_USER}@${VPS_HOST}:${VPS_PATH}${NC}"

    rsync -avz --delete \
      --exclude '.git' \
      --exclude 'node_modules' \
      --exclude 'pnpm-lock.yaml' \
      --exclude '*.log' \
      -e ssh \
      ./ "${VPS_USER}@${VPS_HOST}:${VPS_PATH}/"

    ssh "${VPS_USER}@${VPS_HOST}" "
      cd ${VPS_PATH}
      if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        docker-compose up -d --build
        echo '✔ Deploy via Docker Compose concluído!'
      elif command -v pnpm &> /dev/null; then
        pnpm install --frozen-lockfile
        pnpm build
        pnpm start
      else
        echo '⚠ Nenhum runtime detectado. Instale Docker ou Node.js.'
        exit 1
      fi
    "

    echo -e "${GREEN}✔ VPS deploy concluído!${NC}"
    ;;

  railway)
    echo -e "${CYAN}▶ Deploying to Railway...${NC}"
    if command -v railway &> /dev/null; then
      railway up
      echo -e "${GREEN}✔ Railway deploy concluído!${NC}"
    else
      echo -e "${RED}✘ Railway CLI not found. Install: npm i -g @railway/cli${NC}"
    fi
    ;;

  fly)
    echo -e "${CYAN}▶ Deploying to Fly.io...${NC}"
    if command -v flyctl &> /dev/null; then
      flyctl deploy
      echo -e "${GREEN}✔ Fly.io deploy concluído!${NC}"
    else
      echo -e "${CYAN}ℹ Installing flyctl...${NC}"
      curl -L https://fly.io/install.sh | sh
      flyctl deploy
    fi
    ;;

  docker)
    echo -e "${CYAN}▶ Deploying via Docker Compose...${NC}"
    docker-compose up -d --build
    echo -e "${GREEN}✔ Docker deploy concluído!${NC}"
    ;;

  all)
    echo -e "${PINK}▶ Deploying to ALL configured targets...${NC}"
    if [ -n "${DEPLOY_VPS_HOST:-}" ]; then
      $0 vps
    fi
    if command -v railway &> /dev/null; then
      $0 railway
    fi
    if [ -f fly.toml ]; then
      $0 fly
    fi
    $0 docker
    echo -e "${PINK}✔ All deploys concluídos!${NC}"
    ;;

  help|*)
    show_help
    ;;
esac
