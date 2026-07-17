#!/usr/bin/env node
/**
 * Cyber Claw AI Connector
 * Conector direto com GitHub — webhook listener para auto-deploy
 * 
 * Uso: node deploy/scripts/github-connector.js [porta]
 * 
 * Configure um webhook no seu repositório GitHub apontando para:
 * http://SEU_IP:PORTA/github-webhook
 */

const http = require('http');
const crypto = require('crypto');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const PORT = parseInt(process.argv[2] || process.env.GITHUB_CONNECTOR_PORT || '9999');
const WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET || 'openclaw-cyber-secret';
const DEPLOY_SCRIPT = path.join(__dirname, 'deploy-universal.sh');

function verifySignature(payload, signature, secret) {
  if (!signature) return false;
  const sig = signature.startsWith('sha256=') ? signature.slice(7) : signature;
  const expected = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  return crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(expected));
}

function runDeploy(target) {
  console.log(`\n🚀 Running deploy: ${target}`);
  try {
    const output = execSync(`bash "${DEPLOY_SCRIPT}" ${target}`, {
      cwd: path.join(__dirname, '../..'),
      timeout: 300000,
      maxBuffer: 10 * 1024 * 1024,
    });
    console.log(output.toString());
    return { success: true, output: output.toString() };
  } catch (err) {
    console.error(`❌ Deploy failed: ${err.message}`);
    return { success: false, error: err.message };
  }
}

const server = http.createServer((req, res) => {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Hub-Signature-256');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Health check
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'ok',
      name: 'Cyber Claw AI Connector',
      version: '1.0.0',
      theme: 'cyberpunk-neon',
      timestamp: new Date().toISOString()
    }));
    return;
  }

  // GitHub Webhook
  if (req.method === 'POST' && req.url === '/github-webhook') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      const signature = req.headers['x-hub-signature-256'];
      const event = req.headers['x-github-event'];
      
      // Verify webhook signature
      if (WEBHOOK_SECRET && !verifySignature(body, signature, WEBHOOK_SECRET)) {
        console.warn('⚠ Invalid webhook signature');
        res.writeHead(403);
        res.end('Invalid signature');
        return;
      }

      console.log(`\n📡 GitHub Webhook received: ${event}`);

      try {
        const payload = JSON.parse(body);
        
        if (event === 'push' && payload.ref === 'refs/heads/main' || payload.ref === 'refs/heads/master') {
          console.log(`📦 Push to ${payload.ref} by ${payload.pusher?.name || 'unknown'}`);
          console.log(`💬 ${payload.head_commit?.message || 'No message'}`);
          
          // Trigger deploy
          const result = runDeploy('all');
          
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            status: result.success ? 'deploying' : 'error',
            repository: payload.repository?.full_name,
            commit: payload.head_commit?.id?.slice(0, 7),
            deploy: result
          }));
        } else if (event === 'ping') {
          console.log('🏓 Ping received - webhook is working!');
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'ok', message: 'Webhook configured!' }));
        } else {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'ignored', event }));
        }
      } catch (err) {
        console.error('❌ Error processing webhook:', err.message);
        res.writeHead(400);
        res.end('Invalid payload');
      }
    });
    return;
  }

  // Web interface
  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cyber Claw AI Connector</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body {
            background: #0a0b0e;
            color: #c0caf5;
            font-family: 'Courier New', monospace;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
          }
          .container {
            max-width: 600px;
            padding: 40px;
            border: 1px solid rgba(255, 0, 170, 0.3);
            border-radius: 12px;
            box-shadow: 0 0 30px rgba(255, 0, 170, 0.15);
            text-align: center;
          }
          h1 {
            color: #ff00aa;
            text-shadow: 0 0 20px rgba(255, 0, 170, 0.5);
            margin-bottom: 10px;
            font-size: 2em;
          }
          .status { color: #00ff88; margin: 20px 0; }
          .info { color: #00ccff; margin: 10px 0; font-size: 0.9em; }
          .glow { box-shadow: 0 0 15px rgba(0, 255, 255, 0.2); }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>⚡ OPENCLAW</h1>
          <h2 style="color: #00ffff; margin-bottom: 20px;">GitHub Connector</h2>
          <div class="status">● ONLINE</div>
          <div class="info">Webhook: POST /github-webhook</div>
          <div class="info">Porta: ${PORT}</div>
          <div class="info">Theme: Cyberpunk Neon</div>
        </div>
      </body>
      </html>
    `);
    return;
  }

  res.writeHead(404);
  res.end('Not found');
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`
  ╔══════════════════════════════════════════╗
  ║   🦾 OPENCLAW GITHUB CONNECTOR          ║
  ║   🌐 http://0.0.0.0:${PORT}                  ║
  ║   📡 Webhook: /github-webhook            ║
  ║   ❤ Health:  /health                     ║
  ╚══════════════════════════════════════════╝
  `);
});
