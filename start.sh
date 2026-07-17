#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
PINK='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${PINK}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     🦾 CYBER CLAW AI   ║"
echo "  ║          Inicializando...            ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

# Verifica Node.js
if ! command -v node &> /dev/null; then
  echo -e "${RED}❌ Node.js não encontrado. Instale Node.js 22+.${NC}"
  exit 1
fi

# Verifica se já buildou
if [ ! -f "dist/control-ui/index.html" ]; then
  echo -e "${CYAN}📦 Build não encontrado. Buildando...${NC}"
  cd ui && pnpm build 2>&1 | tail -5
  cd "$SCRIPT_DIR"
fi

PORT="${PORT:-8080}"
HOST="${HOST:-0.0.0.0}"

echo ""
echo -e "${GREEN}✅ Build pronto!${NC}"
echo -e "${CYAN}🌐 Servindo PWA em: http://${HOST}:${PORT}${NC}"
echo -e "${CYAN}📱 Instale como app (Add to Home Screen)${NC}"
echo -e ""
echo -e "${YELLOW}Pressione Ctrl+C para parar${NC}"
echo ""

# Servir com Node.js (http-server leve) ou Python
if command -v npx &> /dev/null && npx --yes serve -h &>/dev/null; then
  npx serve -s dist/control-ui -l "$PORT" --no-request-logging 2>/dev/null
else
  cd dist/control-ui && python3 -m http.server "$PORT" 2>/dev/null
fi
