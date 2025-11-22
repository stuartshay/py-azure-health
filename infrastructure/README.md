# Infrastructure Deployment Guide

This directory contains Azure infrastructure as code (IaC) using Bicep templates and automated deployment workflows via GitHub Actions.

## 📁 Directory Structure

```
infrastructure/
├── bicep/                  # Bicep infrastructure templates
│   ├── main.bicep         # Main entry point
│   └── modules/           # Reusable modules
│       ├── app-insights.bicep
│       ├── function-app.bicep
│       ├── log-analytics.bicep
│       └── storage.bicep
└── scripts/               # Deployment and utility scripts
    ├── setup-github-actions.sh
    ├── deploy-bicep.sh
    ├── get-existing-resources.sh
    └── validate-github-setup.sh
```

## 🚀 Getting Started

### Prerequisites

1. **Azure CLI** - For Azure resource management
2. **GitHub CLI** - For GitHub secrets management
3. **Azure Subscription** - With appropriate permissions
4. **GitHub Repository** - With Actions enabled

### Initial Setup

1. **Configure GitHub Actions with OIDC Authentication**

   ```bash
   cd infrastructure/scripts
   chmod +x *.sh
   ./setup-github-actions.sh
   ```

   This script will:
   - Create Azure AD application for GitHub Actions
   - Configure federated credentials (OIDC) for main, develop, and PR branches
   - Assign necessary Azure permissions (Contributor, User Access Administrator)
   - Set GitHub repository secrets automatically

2. **Validate Setup**

   ```bash
   ./validate-github-setup.sh
   ```

   This verifies:
   - Azure and GitHub CLI authentication
   - Azure AD application and service principal
   - Federated credentials configuration
   - GitHub secrets
   - Workflow files

## 🔧 Deployment Options

### Option 1: GitHub Actions (Recommended)

GitHub Actions workflows provide automated, auditable deployments with built-in security.

#### Infrastructure Deployment

**Workflow:** `.github/workflows/infrastructure-deploy.yml`

1. Navigate to Actions tab in GitHub
2. Select "Infrastructure Deploy" workflow
3. Click "Run workflow"
4. Select environment (dev/staging/prod)
5. Type "deploy" to confirm
6. Click "Run workflow"

**Features:**
- ✅ Automatic validation before deployment
- ✅ Resource group creation if needed
- ✅ Deployment outputs displayed in summary
- ✅ Resource verification after deployment
- ✅ Environment protection rules support

#### Infrastructure Preview (What-If)

**Workflow:** `.github/workflows/infrastructure-whatif.yml`

**Automatic Triggers:**
- Pull requests that modify `infrastructure/bicep/**`
- Pull requests that modify workflow files

**Manual Trigger:**
1. Navigate to Actions tab
2. Select "Infrastructure What-If" workflow
3. Choose environment
4. View predicted changes

**Features:**
- ✅ Shows exactly what will be created/modified/deleted
- ✅ Posts results as PR comment
- ✅ Prevents deployment surprises
- ✅ No actual changes made

#### Infrastructure Destruction

**Workflow:** `.github/workflows/infrastructure-destroy.yml`

⚠️ **Use with caution - destructive operation**

1. Navigate to Actions tab
2. Select "Infrastructure Destroy" workflow
3. Select environment to destroy
4. Choose whether to delete entire resource group
5. Type "destroy" to confirm
6. Click "Run workflow"

**Options:**
- Delete only deployment resources (keeps resource group)
- Delete entire resource group (all resources)

#### Function App Deployment

**Workflow:** `.github/workflows/function-deploy.yml`

**Automatic Triggers:**
- Push to `main` or `develop` branches
- Changes to `src/**`, `requirements.txt`, or workflow file

**Manual Trigger:**
1. Navigate to Actions tab
2. Select "Function Deploy" workflow
3. Choose environment
4. Click "Run workflow"

**Features:**
- ✅ Builds Python function with dependencies
- ✅ Deploys to Azure Functions
- ✅ Tests deployment automatically
- ✅ Displays function URL with access key
- ✅ Automatic artifact cleanup

#### Code Quality Checks

**Workflow:** `.github/workflows/lint-and-test.yml`

**Automatic Triggers:**
- All pull requests
- Push to `main` or `develop` branches

**Manual Trigger:**
1. Navigate to Actions tab
2. Select "Lint and Test" workflow
3. Click "Run workflow"

**Checks Performed:**
- ✅ Code formatting (Black)
- ✅ Import sorting (isort)
- ✅ Linting (Flake8)
- ✅ Type checking (mypy)
- ✅ Secret scanning (GitLeaks)
- ✅ Unit tests (pytest)
- ✅ Code coverage
- ✅ Security vulnerabilities (Safety)
- ✅ Pre-commit hooks

### Option 2: Local Deployment Scripts

For quick local testing or when GitHub Actions isn't available.

#### Deploy Infrastructure

```bash
cd infrastructure/scripts
./deploy-bicep.sh dev deploy
```

**Actions:**
- `deploy` - Full deployment (default)
- `validate` - Validate templates only
- `what-if` - Preview changes

#### View Existing Resources

```bash
./get-existing-resources.sh
```

Shows:
- Subscription information
- Resource groups
- App Service Plans
- Function Apps
- Storage Accounts
- Application Insights
- Recent deployments

## 🏗️ Infrastructure Components

### Resources Deployed

| Resource | Purpose | Module |
|----------|---------|--------|
| **Function App** | Hosts Azure Functions (Python 3.11) | `function-app.bicep` |
| **Storage Account** | Function app storage and artifacts | `storage.bicep` |
| **Application Insights** | Monitoring and telemetry | `app-insights.bicep` |
| **Log Analytics** | Centralized logging | `log-analytics.bicep` |
| **App Service Plan** | Uses existing `azurehealth-plan-dev` | Referenced |

### Environment Configuration

Resources are named with environment suffix:
- **dev**: Development environment
- **staging**: Staging/pre-production
- **prod**: Production environment

### Existing Resources

The deployment references the following existing resources:
- **App Service Plan**: `azurehealth-plan-dev`
- **Shared Resource Group**: `rg-azure-health-shared`

## 🔐 Security

### OIDC Authentication

GitHub Actions uses OpenID Connect (OIDC) for secure authentication:

✅ **Benefits:**
- No client secrets stored in GitHub
- Short-lived tokens
- Automatic rotation
- Audit trail in Azure AD

### Federated Credentials

Configured for:
- `repo:owner/repo:ref:refs/heads/main` - Main branch
- `repo:owner/repo:ref:refs/heads/develop` - Develop branch
- `repo:owner/repo:pull_request` - Pull requests

### GitHub Secrets

Required secrets (automatically set by setup script):
- `AZURE_CLIENT_ID` - Application (client) ID
- `AZURE_TENANT_ID` - Directory (tenant) ID
- `AZURE_SUBSCRIPTION_ID` - Subscription ID
- `AZURE_RESOURCE_GROUP` - Target resource group
- `AZURE_LOCATION` - Azure region

## 📊 Monitoring Deployments

### GitHub Actions

1. Navigate to repository's **Actions** tab
2. Select workflow run to view
3. Expand job to see detailed logs
4. View Summary tab for deployment outputs

### Azure Portal

1. Navigate to Resource Group
2. Select **Deployments** under Settings
3. View deployment history and status
4. Click deployment to see resources and outputs

### Azure CLI

```bash
# List recent deployments
az deployment group list \
  --resource-group rg-azure-health-dev \
  --query '[].{Name:name, State:properties.provisioningState, Timestamp:properties.timestamp}' \
  --output table

# View specific deployment
az deployment group show \
  --resource-group rg-azure-health-dev \
  --name <deployment-name> \
  --query 'properties.outputs'
```

## 🔍 Troubleshooting

### Setup Issues

**Problem:** Azure AD app creation fails
```bash
# Check permissions
az ad app list --display-name "py-azure-health-github-actions"

# Ensure you have Application.ReadWrite.All permission
```

**Problem:** GitHub secrets not set
```bash
# Verify GitHub CLI authentication
gh auth status

# Manually set secret
echo "value" | gh secret set SECRET_NAME
```

### Deployment Issues

**Problem:** Resource group not found
```bash
# Create resource group manually
az group create \
  --name rg-azure-health-dev \
  --location eastus
```

**Problem:** Validation fails
```bash
# Run local validation
cd infrastructure/scripts
./deploy-bicep.sh dev validate
```

**Problem:** Deployment times out
- Check Azure Portal for deployment status
- Review Activity Log for errors
- Verify resource quotas and limits

### Function Deployment Issues

**Problem:** Function app not found
```bash
# Ensure infrastructure is deployed first
./deploy-bicep.sh dev deploy

# Verify function app exists
az functionapp list \
  --resource-group rg-azure-health-dev \
  --query '[].name' \
  --output table
```

**Problem:** Function not responding
```bash
# Check function app status
az functionapp show \
  --name <function-app-name> \
  --resource-group rg-azure-health-dev \
  --query 'state'

# View function logs
az functionapp log tail \
  --name <function-app-name> \
  --resource-group rg-azure-health-dev
```

## 📝 Best Practices

1. **Always run What-If** before production deployments
2. **Use PR workflows** for infrastructure changes
3. **Review deployment outputs** for critical information
4. **Tag resources** appropriately for cost tracking
5. **Monitor Application Insights** for function health
6. **Keep secrets secure** - never commit credentials
7. **Test in dev** before deploying to production
8. **Document changes** in commit messages
9. **Use environment protection rules** for production
10. **Regular security scans** with GitLeaks and Safety

## 🔄 CI/CD Pipeline Flow

```
┌─────────────────┐
│   Code Change   │
└────────┬────────┘
         │
         ├── Infrastructure Change
         │   └──> What-If Analysis (PR)
         │       └──> Manual Deploy (After merge)
         │
         └── Function Code Change
             └──> Lint & Test (PR)
                 └──> Auto Deploy (After merge to main)
```

## 📚 Additional Resources

- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [GitHub Actions for Azure](https://learn.microsoft.com/azure/developer/github/github-actions)
- [Azure Functions Python Developer Guide](https://learn.microsoft.com/azure/azure-functions/functions-reference-python)
- [OIDC with GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

## 💬 Support

For issues or questions:
1. Check this documentation
2. Review workflow logs in GitHub Actions
3. Check Azure Activity Log in Portal
4. Run `validate-github-setup.sh` for diagnostics
5. Open an issue in the repository

---

**Last Updated:** November 2025
**Maintained by:** py-azure-health team
