#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
PINK='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${PINK}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     🦾 CYBER CLAW AI SETUP 🦾      ║"
echo "  ║     Configuração interativa com          ║"
echo "  ║     auto-detecção de APIs de IA          ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Cria .env a partir do exemplo se não existir
if [ ! -f .env ]; then
  cp .env.example.cyber .env
  echo -e "${CYAN}ℹ Arquivo .env criado a partir do template.${NC}"
fi

# Load .env
set -a
source .env
set +a

echo ""
echo -e "${CYAN}${BOLD}▸ AUTO-DETECÇÃO DE APIs DE IA${NC}"
echo -e "${CYAN}  Cole sua API key que eu identifico o provedor!${NC}"
echo ""

read -p "$(echo -e ${YELLOW}"  Digite sua API Key (ou Enter para pular): "${NC})" API_KEY

if [ -n "$API_KEY" ]; then
  # Auto-detecção baseada no padrão da chave
  if [[ "$API_KEY" == sk-ant-* ]]; then
    echo -e "${GREEN}  ✔ Detectado: Anthropic Claude${NC}"
    sed -i "s|ANTHROPIC_API_KEY=|ANTHROPIC_API_KEY=$API_KEY|" .env
  elif [[ "$API_KEY" == sk-or-* ]]; then
    echo -e "${GREEN}  ✔ Detectado: OpenRouter${NC}"
    sed -i "s|OPENROUTER_API_KEY=|OPENROUTER_API_KEY=$API_KEY|" .env
  elif [[ "$API_KEY" == gsk_* ]]; then
    echo -e "${GREEN}  ✔ Detectado: Groq${NC}"
    sed -i "s|GROQ_API_KEY=|GROQ_API_KEY=$API_KEY|" .env
  elif [[ "$API_KEY" == AIza* ]]; then
    echo -e "${GREEN}  ✔ Detectado: Google Gemini${NC}"
    sed -i "s|GOOGLE_API_KEY=|GOOGLE_API_KEY=$API_KEY|" .env
  elif [[ "$API_KEY" == sk-* ]]; then
    echo -e "${CYAN}  ℹ Pode ser OpenAI ou DeepSeek${NC}"
    echo -e "${CYAN}  Escolha o provedor:${NC}"
    select provider in "OpenAI" "DeepSeek" "Outro"; do
      case $provider in
        "OpenAI")
          sed -i "s|OPENAI_API_KEY=|OPENAI_API_KEY=$API_KEY|" .env
          echo -e "${GREEN}  ✔ Configurado como OpenAI${NC}"
          break;;
        "DeepSeek")
          sed -i "s|DEEPSEEK_API_KEY=|DEEPSEEK_API_KEY=$API_KEY|" .env
          echo -e "${GREEN}  ✔ Configurado como DeepSeek${NC}"
          break;;
        "Outro")
          echo -e "${YELLOW}  Digite o nome da variável (ex: MINHA_API):${NC}"
          read custom_var
          echo "${custom_var}=${API_KEY}" >> .env
          echo -e "${GREEN}  ✔ Configurado como ${custom_var}${NC}"
          break;;
      esac
    done
  elif [[ "$API_KEY" == tsk-* ]]; then
    echo -e "${GREEN}  ✔ Detectado: Together AI${NC}"
    sed -i "s|TOGETHER_API_KEY=|TOGETHER_API_KEY=$API_KEY|" .env
  elif [[ "$API_KEY" == R7u* ]]; then
    echo -e "${GREEN}  ✔ Detectado: Mistral AI${NC}"
    sed -i "s|MISTRAL_API_KEY=|MISTRAL_API_KEY=$API_KEY|" .env
  else
    echo -e "${YELLOW}  ⚠ Formato não reconhecido. Vou tentar configurar mesmo assim.${NC}"
    echo "CUSTOM_API_KEY=${API_KEY}" >> .env
    echo -e "${GREEN}  ✔ Salva como CUSTOM_API_KEY${NC}"
  fi
fi

echo ""
echo -e "${CYAN}${BOLD}▸ GITHUB INTEGRATION${NC}"
read -p "$(echo -e ${YELLOW}"  Token GitHub (ou Enter para pular): "${NC})" GH_TOKEN
if [ -n "$GH_TOKEN" ]; then
  sed -i "s|GITHUB_TOKEN=|GITHUB_TOKEN=$GH_TOKEN|" .env
  echo -e "${GREEN}  ✔ GitHub token configurado${NC}"
fi

read -p "$(echo -e ${YELLOW}"  Seu repositório GitHub (ex: user/repo): "${NC})" GH_REPO
if [ -n "$GH_REPO" ]; then
  sed -i "s|GITHUB_REPO=|GITHUB_REPO=$GH_REPO|" .env
  # Configura remote do git
  git remote set-url origin "https://github.com/${GH_REPO}.git" 2>/dev/null || \
    git remote add origin "https://github.com/${GH_REPO}.git" 2>/dev/null || true
  echo -e "${GREEN}  ✔ Repositório configurado${NC}"
fi

echo ""
echo -e "${CYAN}${BOLD}▸ VPS DEPLOY${NC}"
read -p "$(echo -e ${YELLOW}"  VPS Host (IP ou domínio): "${NC})" VPS_HOST
if [ -n "$VPS_HOST" ]; then
  sed -i "s|DEPLOY_VPS_HOST=|DEPLOY_VPS_HOST=$VPS_HOST|" .env
  read -p "$(echo -e ${YELLOW}"  VPS User (padrão: root): "${NC})" VPS_USER
  sed -i "s|DEPLOY_VPS_USER=root|DEPLOY_VPS_USER=${VPS_USER:-root}|" .env
  read -p "$(echo -e ${YELLOW}"  VPS Path (padrão: /opt/openclaw): "${NC})" VPS_PATH
  sed -i "s|DEPLOY_VPS_PATH=/opt/openclaw|DEPLOY_VPS_PATH=${VPS_PATH:-/opt/openclaw}|" .env
  echo -e "${GREEN}  ✔ VPS configurada${NC}"
fi

echo ""
echo -e "${PINK}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     ✅ SETUP CONCLUÍDO!                  ║"
echo "  ║                                          ║"
echo "  ║  Para iniciar o Cyber Claw AI:                ║"
echo "  ║  docker-compose up -d                    ║"
echo "  ║                                          ║"
echo "  ║  Para deployar:                          ║"
echo "  ║  ./deploy/scripts/deploy-universal.sh    ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
