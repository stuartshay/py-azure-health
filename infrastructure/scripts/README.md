# Infrastructure Scripts

This directory contains helper scripts for Azure infrastructure deployment and management.

## Scripts Overview

### 🚀 setup-github-actions.sh
**Purpose:** One-time setup for GitHub Actions OIDC authentication with Azure

**Usage:**
```bash
./setup-github-actions.sh
```

**What it does:**
- Creates Azure AD application for GitHub Actions
- Configures federated credentials (OIDC) for main, develop, and PR branches
- Assigns Contributor and User Access Administrator roles
- Sets GitHub repository secrets automatically

**Prerequisites:**
- Azure CLI authenticated (`az login`)
- GitHub CLI authenticated (`gh auth login`)
- Appropriate Azure permissions
- Repository with remote configured

---

### 🏗️ deploy-bicep.sh
**Purpose:** Deploy infrastructure using Bicep templates

**Usage:**
```bash
./deploy-bicep.sh [environment] [action]

# Examples
./deploy-bicep.sh dev deploy         # Deploy to dev
./deploy-bicep.sh staging validate   # Validate staging templates
./deploy-bicep.sh prod what-if       # Preview prod changes
```

**Arguments:**
- `environment`: dev, staging, or prod (default: dev)
- `action`: deploy, validate, or what-if (default: deploy)

**Environment Variables:**
- `AZURE_RESOURCE_GROUP`: Target resource group (default: rg-azure-health-dev)
- `AZURE_LOCATION`: Azure region (default: eastus)

---

### 📋 get-existing-resources.sh
**Purpose:** List existing Azure resources for the project

**Usage:**
```bash
./get-existing-resources.sh
```

**Shows:**
- Subscription information
- Resource groups
- App Service Plans
- Function Apps
- Storage Accounts
- Application Insights components
- Recent deployment history

---

### ✅ validate-github-setup.sh
**Purpose:** Validate GitHub Actions configuration

**Usage:**
```bash
./validate-github-setup.sh
```

**Validates:**
- Azure CLI and GitHub CLI installation and authentication
- Azure AD application existence
- Federated credentials configuration
- Azure role assignments
- GitHub repository secrets
- Workflow files presence

**Exit Codes:**
- 0: All checks passed
- 1: Validation failed (errors found)

---

## Quick Start Guide

### First Time Setup

1. **Authenticate with Azure and GitHub:**
   ```bash
   az login
   gh auth login
   ```

2. **Run GitHub Actions setup:**
   ```bash
   ./setup-github-actions.sh
   ```

3. **Validate setup:**
   ```bash
   ./validate-github-setup.sh
   ```

4. **View existing resources:**
   ```bash
   ./get-existing-resources.sh
   ```

5. **Deploy infrastructure:**
   ```bash
   ./deploy-bicep.sh dev deploy
   ```

### Subsequent Deployments

Use GitHub Actions workflows (recommended) or:

```bash
# Preview changes first
./deploy-bicep.sh dev what-if

# Deploy if changes look good
./deploy-bicep.sh dev deploy
```

## Common Tasks

### Check what's deployed
```bash
./get-existing-resources.sh
```

### Validate Bicep templates
```bash
./deploy-bicep.sh dev validate
```

### Preview infrastructure changes
```bash
./deploy-bicep.sh dev what-if
```

### Deploy to different environments
```bash
./deploy-bicep.sh dev deploy      # Development
./deploy-bicep.sh staging deploy  # Staging
./deploy-bicep.sh prod deploy     # Production
```

### Troubleshoot GitHub Actions setup
```bash
./validate-github-setup.sh
```

## Tips

- **Always run what-if** before deploying to production
- **Use validate** to check template syntax before deployment
- **Run get-existing-resources** to understand current state
- **Check validate-github-setup** if workflows fail
- Scripts use colors for better readability (green=success, red=error, yellow=warning)

## Environment Variables

Set these for custom configurations:

```bash
export AZURE_RESOURCE_GROUP="rg-custom-name"
export AZURE_LOCATION="westus2"
./deploy-bicep.sh dev deploy
```

## Error Handling

All scripts:
- Exit on first error (`set -e`)
- Provide colored output for clarity
- Show detailed error messages
- Return non-zero exit codes on failure

## Security Notes

- Never commit credentials or secrets
- Scripts use OIDC (no secrets stored in GitHub)
- Azure CLI uses your authenticated session
- GitHub CLI uses your authenticated session
- Secrets are set programmatically, never echoed

---

**For more information, see:** [infrastructure/README.md](../README.md)
