# Railway Deployment Testing Guide

This guide will help you test your OpenHands deployment on Railway.

## Prerequisites

Before testing, ensure you have:

- [ ] Railway account ([Sign up here](https://railway.app))
- [ ] Railway CLI installed
- [ ] An LLM API key (OpenAI, Anthropic, etc.)
- [ ] A runtime provider account (E2B or Modal recommended)

## Quick Setup

### Method 1: Using the Setup Script (Recommended)

Run the interactive setup script:

```bash
./railway-setup.sh
```

This will guide you through:
1. Railway CLI login
2. Project initialization
3. Environment variable configuration
4. Runtime selection
5. Deployment

### Method 2: Manual Setup

If you prefer manual setup, follow these steps:

#### 1. Install Railway CLI

**macOS/Linux:**
```bash
# Using Homebrew
brew install railway

# Or using npm
npm install -g @railway/cli

# Or using curl
curl -fsSL https://railway.app/install.sh | sh
```

**Windows:**
```powershell
npm install -g @railway/cli
```

#### 2. Login to Railway

```bash
railway login
```

This will open a browser window for authentication.

#### 3. Initialize Your Project

**For a new project:**
```bash
railway init
```

**For an existing project:**
```bash
railway link
```

#### 4. Set Environment Variables

**Required Variables:**

```bash
# LLM Configuration
railway variables set LLM_API_KEY="your-openai-api-key"
railway variables set LLM_MODEL="gpt-4o"

# Security
railway variables set JWT_SECRET="$(openssl rand -hex 32)"

# Workspace
railway variables set WORKSPACE_BASE="/opt/workspace_base"
railway variables set WORKSPACE_MOUNT_PATH="/opt/workspace_base"

# File Storage
railway variables set FILE_STORE="local"
railway variables set FILE_STORE_PATH="/.openhands"

# Sandbox
railway variables set SANDBOX_RUNTIME_CONTAINER_IMAGE="docker.openhands.dev/openhands/runtime:1.2-nikolaik"
```

**Runtime Configuration (Choose ONE):**

**Option A: E2B Runtime (Recommended)**
```bash
railway variables set RUNTIME="e2b"
railway variables set E2B_API_KEY="your-e2b-api-key"
```

Get E2B API key at: https://e2b.dev/dashboard

**Option B: Modal Runtime**
```bash
railway variables set RUNTIME="modal"
railway variables set MODAL_API_KEY="your-modal-api-key"
railway variables set MODAL_SECRET="your-modal-secret"
```

Get Modal credentials at: https://modal.com/settings

**Option C: Remote Docker**
```bash
railway variables set RUNTIME="docker"
railway variables set DOCKER_HOST="tcp://your-docker-host:2375"
```

⚠️ **Security Warning:** Only use with a properly secured Docker daemon.

**Optional Variables:**

```bash
# Development
railway variables set DEBUG="false"

# Limits
railway variables set MAX_ITERATIONS="500"
railway variables set MAX_BUDGET_PER_TASK="0.0"

# Security
railway variables set CONFIRMATION_MODE="false"
railway variables set ENABLE_SECURITY_ANALYZER="true"
```

#### 5. Deploy

```bash
railway up
```

Or to deploy from GitHub:
```bash
# Link your GitHub repository in Railway dashboard
# Railway will auto-deploy on push
```

## Testing Your Deployment

### 1. Check Deployment Status

```bash
# View deployment status
railway status

# View logs
railway logs

# Follow logs in real-time
railway logs --follow
```

### 2. Get Your Application URL

```bash
# Open the deployed app in browser
railway open

# Or get the URL
railway domain
```

### 3. Test the Application

Once deployed, test these endpoints:

#### Health Check (if implemented)
```bash
curl https://your-app.railway.app/health
```

#### API Status
```bash
curl https://your-app.railway.app/api/status
```

#### Web Interface
Open in browser:
```
https://your-app.railway.app
```

### 4. Test LLM Integration

1. Open the application in your browser
2. Create a new conversation
3. Send a simple test message: "Hello, can you help me write a Python function?"
4. Verify the AI responds correctly

### 5. Test Code Execution

1. Ask the AI to write a simple Python script
2. Ask it to execute the script
3. Verify that code execution works (this tests your runtime configuration)

Example prompts:
- "Write a Python script that prints Hello World"
- "Create a function that calculates fibonacci numbers"
- "Write and run a test for the function"

## Troubleshooting

### Issue: Deployment Fails

**Check build logs:**
```bash
railway logs --deployment
```

**Common causes:**
- Missing environment variables
- Incorrect Dockerfile path
- Build timeout (increase resources in Railway dashboard)

### Issue: Application Won't Start

**Check runtime logs:**
```bash
railway logs --follow
```

**Common causes:**
- Missing `PORT` environment variable (Railway should provide this automatically)
- Missing required environment variables
- Runtime configuration errors

### Issue: "Cannot connect to Docker daemon"

**Solution:** You're using Docker runtime on Railway (not supported)

```bash
# Switch to E2B or Modal
railway variables set RUNTIME="e2b"
railway variables set E2B_API_KEY="your-e2b-api-key"

# Redeploy
railway up
```

### Issue: LLM Errors

**Check your API key:**
```bash
railway variables get LLM_API_KEY
```

**Verify the key is valid:**
- For OpenAI: Test at https://platform.openai.com/api-keys
- For Anthropic: Test at https://console.anthropic.com/settings/keys

**Check model availability:**
```bash
# Ensure the model name is correct
railway variables set LLM_MODEL="gpt-4o"
```

### Issue: High Costs

**Set budget limits:**
```bash
railway variables set MAX_BUDGET_PER_TASK="10.0"  # $10 max per task
railway variables set MAX_ITERATIONS="100"         # Limit iterations
```

**Use cheaper models for testing:**
```bash
railway variables set LLM_MODEL="gpt-4o-mini"
```

### Issue: Slow Performance

**Check your Railway plan:**
- Free tier has resource limits
- Consider upgrading to Pro plan

**Optimize settings:**
```bash
# Reduce max iterations
railway variables set MAX_ITERATIONS="200"

# Use faster models
railway variables set LLM_MODEL="gpt-4o-mini"
```

## Advanced Testing

### Load Testing

Test with multiple concurrent requests:

```bash
# Install hey (HTTP load testing tool)
brew install hey  # macOS
# or apt-get install hey  # Linux

# Run load test
hey -n 100 -c 10 https://your-app.railway.app/
```

### Environment Variable Testing

```bash
# List all variables
railway variables

# Get specific variable
railway variables get LLM_MODEL

# Delete variable
railway variables delete DEBUG

# Set multiple at once
railway variables set \
  DEBUG=true \
  MAX_ITERATIONS=300
```

### Database Testing (if using PostgreSQL)

```bash
# Add PostgreSQL
railway add --service postgres

# Connect to database
railway run psql

# Check connection in app logs
railway logs --follow | grep -i postgres
```

## Monitoring

### View Metrics

Go to your Railway dashboard:
1. Click on your project
2. View the "Metrics" tab
3. Monitor:
   - CPU usage
   - Memory usage
   - Network traffic
   - Request count

### Set Up Alerts

Configure alerts in Railway dashboard:
1. Go to project settings
2. Configure notifications for:
   - Deployment failures
   - High resource usage
   - Application crashes

### Cost Monitoring

Track costs in Railway:
1. View usage in dashboard
2. Set budget alerts
3. Monitor LLM API costs separately

## Rollback

If something goes wrong:

```bash
# View deployment history
railway history

# Rollback to previous deployment
railway rollback
```

## Cleanup

To stop and remove the deployment:

```bash
# Stop the service
railway down

# Or delete the entire project
railway delete
```

## Performance Benchmarks

Expected performance on Railway:

- **Startup time:** 30-60 seconds
- **Response time:** 1-3 seconds (excluding LLM latency)
- **Memory usage:** 500MB-2GB (depending on load)
- **Build time:** 3-5 minutes

## Next Steps

After successful testing:

1. **Configure custom domain** (Railway Settings → Domains)
2. **Set up monitoring** (integrate with Datadog, Sentry, etc.)
3. **Enable authentication** (configure JWT, OAuth)
4. **Add database** (for conversation persistence)
5. **Configure backups** (for workspace data)
6. **Set up CI/CD** (auto-deploy from GitHub)

## Getting Help

If you encounter issues:

1. Check Railway logs: `railway logs`
2. Review Railway documentation: https://docs.railway.app
3. Check OpenHands docs: https://docs.openhands.dev
4. Open an issue: https://github.com/OpenHands/OpenHands/issues

## Security Checklist

Before going to production:

- [ ] Change default JWT_SECRET to a strong random value
- [ ] Enable CONFIRMATION_MODE for sensitive operations
- [ ] Set MAX_BUDGET_PER_TASK to prevent runaway costs
- [ ] Configure proper CORS settings
- [ ] Enable HTTPS (Railway provides this by default)
- [ ] Set up authentication (OAuth, API keys)
- [ ] Review security analyzer settings
- [ ] Limit file upload sizes
- [ ] Configure rate limiting
- [ ] Set up monitoring and alerts

## Cost Estimation

### Railway Costs:
- **Free Tier:** $5 credit/month
- **Pro Plan:** $20/month + usage-based pricing
- **Estimated monthly cost:** $10-50 (depending on traffic)

### LLM API Costs (examples):
- **GPT-4o:** ~$5-15 per 1M input tokens
- **GPT-4o-mini:** ~$0.15-0.60 per 1M tokens
- **Claude Sonnet:** ~$3-15 per 1M tokens

### Runtime Costs:
- **E2B:** ~$0.10-1.00 per hour of active usage
- **Modal:** Pay per execution time
- **Remote Docker:** Your infrastructure costs

**Total estimated monthly cost:** $30-100 (light usage) to $200-500+ (heavy usage)

---

**Happy Testing! 🚀**

For more information, see [RAILWAY.md](./RAILWAY.md)
