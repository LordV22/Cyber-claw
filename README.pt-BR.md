# 🦾 OPENCLAW — Cyberpunk Neon Edition

**Gateway de IA multi-provedor com interface PWA cyberpunk, deploy universal e conector GitHub.**

![Cyberpunk Theme](https://img.shields.io/badge/Theme-Cyberpunk_Neon-ff00aa)
![PWA](https://img.shields.io/badge/PWA-Ready-00ffff)
![License](https://img.shields.io/badge/License-MIT-green)
![Deploy](https://img.shields.io/badge/Deploy-Universal-ffaa00)

---

## ⚡ O QUE É?

Cyber Claw AI é um **gateway de IA completo** que conecta você a **dezenas de provedores** (OpenAI, Anthropic, Google, Groq, OpenRouter, Ollama, etc.) em uma única interface. Agora com **visual cyberpunk neon** e **deploy em qualquer lugar**.

## ✨ FUNCIONALIDADES

### 🤖 IA Multi-Provedor
- OpenAI (GPT-4, GPT-5, DALL-E)
- Anthropic (Claude Opus, Sonnet, Haiku)
- Google (Gemini, Vertex AI)
- Groq (rápido e gratuito!)
- OpenRouter (acesso a 300+ modelos)
- Ollama (local, 100% gratuito)
- DeepSeek, Mistral, Together AI, Cohere, Perplexity...
- **Auto-detecção**: Cole sua API key que o sistema reconhece o provedor!

### 🎨 Tema Cyberpunk Neon
- Fundo escuro profundo com detalhes neon
- Cores vibrantes: rosa, ciano, verde neon
- Efeitos glow em bordas, scrollbars e seleções
- Texto de alto contraste para máxima legibilidade
- Scrollbar neon personalizada

### 📱 PWA (Progressive Web App)
- Funciona offline via Service Worker
- Instalável como app no celular/desktop
- Notificações push
- Cache inteligente de assets
- Carregamento instantâneo

### 🚀 Deploy Universal
| Plataforma | Comando |
|------------|---------|
| **Docker** | `docker-compose up -d` |
| **VPS (SSH)** | `./deploy/scripts/deploy-universal.sh vps` |
| **Railway** | `./deploy/scripts/deploy-universal.sh railway` |
| **Fly.io** | `./deploy/scripts/deploy-universal.sh fly` |
| **GitHub Actions** | Push na main → deploy automático |

### 🔗 Conector GitHub Direto
- Webhook listener para auto-deploy no push
- Painel de status em tempo real
- Integração com GitHub Actions
- Deploy automático para VPS, Railway ou Fly.io

## 🚀 COMEÇAR RÁPIDO

```bash
# 1. Clone
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 2. Setup interativo (recomendado!)
chmod +x deploy/scripts/setup-interactive.sh
./deploy/scripts/setup-interactive.sh

# 3. Iniciar com Docker
docker-compose up -d

# 4. Acessar
# → http://localhost:3000
```

## 🔧 CONFIGURAÇÃO MANUAL

```bash
# Copie o arquivo de configuração
cp .env.example.cyber .env

# Edite com suas chaves de API
nano .env

# Inicie
docker-compose up -d
```

## 📡 GITHUB CONNECTOR

Para ativar o conector GitHub direto:

```bash
# Inicie o webhook listener
node deploy/scripts/github-connector.js 9999

# Configure no GitHub:
# Repositório → Settings → Webhooks → Add webhook
# Payload URL: http://SEU_IP:9999/github-webhook
# Secret: openclaw-cyber-secret
```

## 🎨 TEMAS

O Cyber Claw AI vem com 4 temas:

| Tema | Descrição |
|------|-----------|
| **Claw** | Padrão, vermelho elegante |
| **Knot** | Preto e vermelho |
| **Dash** | Azul chocolate |
| **Cyber** | **Cyberpunk Neon** (novo!) |

Para selecionar: Configurações → Aparência → Tema

## 🤝 PROVEDORES GRATUITOS

| Provedor | Como conseguir |
|----------|---------------|
| **Groq** | groq.com — cadastro grátis, créditos gratuitos |
| **Google Gemini** | aistudio.google.com — API gratuita |
| **OpenRouter** | openrouter.ai — créditos iniciais |
| **Ollama** | ollama.ai — 100% local e gratuito |
| **Claude** | anthropic.com — trial gratuito |

## 📦 ESTRUTURA DO PROJETO

```
openclaw/
├── ui/                  # Interface PWA (Vite + Lit)
│   ├── public/          # Assets estáticos, manifest, sw
│   ├── src/             # Código da interface
│   └── index.html       # Entry point PWA
├── src/                 # Core do gateway
├── deploy/              # Scripts de deploy
│   └── scripts/         # Deploy universal, setup, connector
├── docker-compose.yml   # Docker Compose
├── Dockerfile           # Docker image
└── .env.example.cyber   # Config cyberpunk
```

## LICENÇA

MIT — Cyber Claw AI Foundation. Totalmente livre e open source.

---

<div align="center">
  <strong>⚡ Cyber Claw AI Cyberpunk Neon ⚡</strong><br>
  <em>IA sem limites. Visual sem igual.</em>
</div>
