# Quick Reference Guide

## 🚀 Get Started in 3 Steps

### 1. Setup GitHub Actions (One-Time)
```bash
cd infrastructure/scripts
./setup-github-actions.sh
```

### 2. Validate Configuration
```bash
./validate-github-setup.sh
```

### 3. Deploy Infrastructure
**Via GitHub Actions:**
- Go to Actions → Infrastructure Deploy → Run workflow

**Via Local Script:**
```bash
./deploy-bicep.sh dev deploy
```

---

## 📋 Common Commands

### Setup & Validation
```bash
# Initial setup
cd infrastructure/scripts
./setup-github-actions.sh

# Validate setup
./validate-github-setup.sh

# View existing resources
./get-existing-resources.sh
```

### Local Deployment
```bash
# Preview changes (recommended first)
./deploy-bicep.sh dev what-if

# Validate templates
./deploy-bicep.sh dev validate

# Deploy infrastructure
./deploy-bicep.sh dev deploy

# Deploy to other environments
./deploy-bicep.sh staging deploy
./deploy-bicep.sh prod deploy
```

### Development
```bash
# Start function locally
cd /workspaces/py-azure-health
func start --script-root src

# Run tests
pytest src/tests/ -v

# Run with coverage
pytest src/tests/ --cov=. --cov-report=html

# Format code
black src/
isort src/

# Lint code
flake8 src/

# Run all pre-commit hooks
pre-commit run --all-files
```

### Azure CLI
```bash
# Login
az login

# List deployments
az deployment group list \
  --resource-group rg-azure-health-dev \
  --output table

# Get deployment outputs
az deployment group show \
  --resource-group rg-azure-health-dev \
  --name <deployment-name> \
  --query properties.outputs

# List function apps
az functionapp list \
  --resource-group rg-azure-health-dev \
  --output table

# View function logs
az functionapp log tail \
  --name <function-app-name> \
  --resource-group rg-azure-health-dev
```

### GitHub CLI
```bash
# Check auth status
gh auth status

# List secrets
gh secret list

# Set a secret
echo "value" | gh secret set SECRET_NAME

# Trigger workflow
gh workflow run infrastructure-deploy.yml

# View workflow runs
gh run list --workflow=function-deploy.yml
```

---

## 🔗 GitHub Actions Workflows

### infrastructure-deploy.yml
**Trigger:** Manual
**Purpose:** Deploy Azure infrastructure
**Steps:** Actions → Infrastructure Deploy → Select env → Type "deploy" → Run

### infrastructure-whatif.yml
**Trigger:** PRs touching `infrastructure/bicep/**`, Manual
**Purpose:** Preview infrastructure changes
**Steps:** Automatic on PR or Actions → Infrastructure What-If → Run

### infrastructure-destroy.yml
**Trigger:** Manual
**Purpose:** Remove Azure resources
**Steps:** Actions → Infrastructure Destroy → Select env → Type "destroy" → Run

### function-deploy.yml
**Trigger:** Push to main/develop with `src/**` changes, Manual
**Purpose:** Deploy function code
**Steps:** Automatic or Actions → Function Deploy → Select env → Run

### lint-and-test.yml
**Trigger:** All PRs, Push to main/develop, Manual
**Purpose:** Code quality checks
**Steps:** Automatic or Actions → Lint and Test → Run

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `infrastructure/README.md` | Complete deployment guide |
| `infrastructure/scripts/README.md` | Script documentation |
| `SETUP_COMPLETE.md` | Implementation summary |
| `pyproject.toml` | Tool configuration |
| `.github/workflows/*.yml` | CI/CD workflows |
| `infrastructure/bicep/main.bicep` | Main infrastructure template |
| `src/tests/*.py` | Unit tests |

---

## 🎯 Quick Tasks

### Deploy Everything from Scratch
```bash
# 1. Setup
cd infrastructure/scripts
./setup-github-actions.sh

# 2. Deploy infrastructure
# Go to GitHub Actions → Infrastructure Deploy → Run

# 3. Deploy function
# Automatic on push to main, or run Function Deploy workflow
```

### Check Deployment Status
```bash
# View resources
cd infrastructure/scripts
./get-existing-resources.sh

# Or use Azure CLI
az resource list \
  --resource-group rg-azure-health-dev \
  --output table
```

### Update Function Code
```bash
# 1. Make changes to src/function_app.py
# 2. Push to main branch
# 3. Function Deploy workflow runs automatically
```

### Preview Infrastructure Changes
```bash
# Local
cd infrastructure/scripts
./deploy-bicep.sh dev what-if

# GitHub Actions
# Create PR → What-If runs automatically
```

### Run Quality Checks
```bash
# Local
pre-commit run --all-files
pytest src/tests/ -v

# GitHub Actions
# Create PR → Lint and Test runs automatically
```

---

## 🆘 Troubleshooting

### Setup fails
```bash
# Check authentication
az account show
gh auth status

# Re-authenticate if needed
az login
gh auth login

# Run validation
./validate-github-setup.sh
```

### Deployment fails
```bash
# Check Azure deployment logs
az deployment group list \
  --resource-group rg-azure-health-dev

# View specific deployment
az deployment group show \
  --resource-group rg-azure-health-dev \
  --name <deployment-name>

# Check Activity Log in Azure Portal
```

### Function not working
```bash
# Check function app status
az functionapp show \
  --name <function-app-name> \
  --resource-group rg-azure-health-dev \
  --query state

# View logs
az functionapp log tail \
  --name <function-app-name> \
  --resource-group rg-azure-health-dev

# Restart function app
az functionapp restart \
  --name <function-app-name> \
  --resource-group rg-azure-health-dev
```

---

## 📖 Documentation

- **[infrastructure/README.md](infrastructure/README.md)** - Complete deployment guide
- **[infrastructure/scripts/README.md](infrastructure/scripts/README.md)** - Script reference
- **[SETUP_COMPLETE.md](SETUP_COMPLETE.md)** - Implementation summary
- **[README.md](README.md)** - Project overview

---

## 💡 Pro Tips

1. **Always run what-if** before deploying to production
2. **Use PRs** for infrastructure changes to get automatic what-if previews
3. **Monitor Application Insights** for function performance
4. **Keep local.settings.json** in sync with Azure configuration
5. **Run pre-commit hooks** before committing
6. **Use validate-github-setup.sh** when workflows fail
7. **Check SETUP_COMPLETE.md** for comprehensive details

---

**Need help?** Check [infrastructure/README.md](infrastructure/README.md) for detailed troubleshooting.
