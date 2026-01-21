# Railway Quick Start Guide

## 🚀 Deploy in 5 Minutes

### Option 1: Interactive Setup (Easiest)

```bash
# 1. Run the setup script
./railway-setup.sh

# 2. Follow the prompts to configure your deployment

# 3. Done! Your app is deploying
```

### Option 2: One-Command Deploy

```bash
# Set all variables at once (replace with your actual values)
railway variables set \
  LLM_API_KEY="sk-your-key-here" \
  LLM_MODEL="gpt-4o" \
  JWT_SECRET="$(openssl rand -hex 32)" \
  RUNTIME="e2b" \
  E2B_API_KEY="your-e2b-key" \
  WORKSPACE_BASE="/opt/workspace_base" \
  WORKSPACE_MOUNT_PATH="/opt/workspace_base" \
  FILE_STORE="local" \
  FILE_STORE_PATH="/.openhands" \
  SANDBOX_RUNTIME_CONTAINER_IMAGE="docker.openhands.dev/openhands/runtime:1.2-nikolaik" \
  DEBUG="false" \
  MAX_ITERATIONS="500" \
  MAX_BUDGET_PER_TASK="0.0"

# Deploy
railway up
```

## 📋 Essential Commands

```bash
# Setup
railway login              # Login to Railway
railway init              # Initialize new project
railway link              # Link to existing project

# Configuration
railway variables         # List all variables
railway variables set KEY=value
railway variables get KEY
railway variables delete KEY

# Deployment
railway up                # Deploy your app
railway deploy            # Alternative deploy command
railway status            # Check deployment status

# Monitoring
railway logs              # View logs
railway logs --follow     # Stream logs in real-time
railway open              # Open app in browser
railway domain            # Get app URL

# Management
railway down              # Stop the service
railway restart           # Restart the service
railway rollback          # Rollback to previous version
railway delete            # Delete project
```

## ⚡ Quick Validation

Before deploying, validate your setup:

```bash
./railway-validate.sh
```

This checks that all required environment variables are set.

## 🔑 Required Environment Variables

**Minimum required:**

```bash
LLM_API_KEY               # Your OpenAI/Anthropic API key
LLM_MODEL                 # Model name (e.g., "gpt-4o")
JWT_SECRET                # Random secret for auth
RUNTIME                   # "e2b", "modal", or "docker"
E2B_API_KEY               # If using E2B runtime
WORKSPACE_BASE            # "/opt/workspace_base"
WORKSPACE_MOUNT_PATH      # "/opt/workspace_base"
FILE_STORE                # "local"
FILE_STORE_PATH           # "/.openhands"
```

## 🎯 Runtime Options

### E2B (Recommended)

```bash
railway variables set RUNTIME="e2b"
railway variables set E2B_API_KEY="your-key"
```

Get API key: https://e2b.dev/dashboard

### Modal

```bash
railway variables set RUNTIME="modal"
railway variables set MODAL_API_KEY="your-key"
railway variables set MODAL_SECRET="your-secret"
```

Get credentials: https://modal.com/settings

### Remote Docker

```bash
railway variables set RUNTIME="docker"
railway variables set DOCKER_HOST="tcp://host:2375"
```

⚠️ Requires secure Docker daemon setup

## 🔍 Troubleshooting

### "Cannot connect to Docker daemon"

```bash
# Switch to E2B
railway variables set RUNTIME="e2b"
railway variables set E2B_API_KEY="your-key"
railway up
```

### Check logs

```bash
railway logs --follow
```

### Verify variables

```bash
railway variables
```

### Restart deployment

```bash
railway restart
```

## 📊 Monitoring

```bash
# Real-time logs
railway logs --follow

# Filter logs
railway logs --follow | grep ERROR

# Check status
railway status

# View in dashboard
railway dashboard
```

## 💰 Cost Management

```bash
# Set budget limits
railway variables set MAX_BUDGET_PER_TASK="10.0"
railway variables set MAX_ITERATIONS="100"

# Use cheaper model
railway variables set LLM_MODEL="gpt-4o-mini"
```

## 🔗 Quick Links

- **Railway Dashboard:** https://railway.app/dashboard
- **E2B Dashboard:** https://e2b.dev/dashboard
- **Modal Dashboard:** https://modal.com/dashboard
- **OpenHands Docs:** https://docs.openhands.dev

## 📚 Full Documentation

For detailed guides, see:
- [RAILWAY.md](./RAILWAY.md) - Complete deployment guide
- [RAILWAY-TESTING.md](./RAILWAY-TESTING.md) - Testing guide
- [.env.railway.example](./.env.railway.example) - All environment variables

## 🆘 Get Help

1. Check Railway logs: `railway logs`
2. Validate config: `./railway-validate.sh`
3. Review docs: [RAILWAY.md](./RAILWAY.md)
4. Open issue: https://github.com/OpenHands/OpenHands/issues

---

**Need more details?** See [RAILWAY-TESTING.md](./RAILWAY-TESTING.md) for comprehensive testing guide.
