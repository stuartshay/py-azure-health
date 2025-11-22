#!/bin/bash

################################################################################
# GitHub Actions OIDC Setup Script for Azure
#
# This script configures Azure AD application with federated credentials for
# GitHub Actions to authenticate securely without storing client secrets.
#
# Prerequisites:
# - Azure CLI (az) installed and authenticated
# - GitHub CLI (gh) installed and authenticated
# - Appropriate Azure permissions to create AD applications and assign roles
# - Repository must be initialized with a remote
#
# Usage:
#   ./setup-github-actions.sh
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="py-azure-health-github-actions"
REPO_OWNER=""
REPO_NAME=""
SUBSCRIPTION_ID=""
RESOURCE_GROUP="rg-azure-health-dev"
LOCATION="eastus"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI not found. Please install it first."
        exit 1
    fi
    print_success "Azure CLI found"

    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not found. Please install it first."
        exit 1
    fi
    print_success "GitHub CLI found"

    # Check Azure login
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run: az login"
        exit 1
    fi
    print_success "Logged in to Azure"

    # Check GitHub authentication
    if ! gh auth status &> /dev/null; then
        print_error "Not logged in to GitHub. Please run: gh auth login"
        exit 1
    fi
    print_success "Logged in to GitHub"

    # Get repository information
    if ! REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null); then
        print_error "Unable to determine repository. Make sure you're in a git repository with a remote."
        exit 1
    fi
    REPO_OWNER=$(echo "$REPO_INFO" | cut -d'/' -f1)
    REPO_NAME=$(echo "$REPO_INFO" | cut -d'/' -f2)
    print_success "Repository detected: $REPO_OWNER/$REPO_NAME"

    # Get subscription
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    print_success "Using subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
}

create_azure_ad_app() {
    print_header "Creating Azure AD Application"

    # Check if app already exists
    if APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv 2>/dev/null) && [ -n "$APP_ID" ]; then
        print_warning "Application '$APP_NAME' already exists with App ID: $APP_ID"
        print_info "Using existing application..."
    else
        # Create the application
        APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
        print_success "Created Azure AD application: $APP_ID"
        sleep 5  # Wait for AD replication
    fi

    # Get or create service principal
    if SP_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --query "[0].id" -o tsv 2>/dev/null) && [ -n "$SP_ID" ]; then
        print_success "Service principal already exists: $SP_ID"
    else
        SP_ID=$(az ad sp create --id "$APP_ID" --query id -o tsv)
        print_success "Created service principal: $SP_ID"
        sleep 5  # Wait for AD replication
    fi
}

create_federated_credentials() {
    print_header "Creating Federated Credentials"

    # Main branch credential
    print_info "Setting up federated credential for main branch..."
    MAIN_CRED_NAME="github-actions-main"
    if az ad app federated-credential show --id "$APP_ID" --federated-credential-id "$MAIN_CRED_NAME" &> /dev/null; then
        print_warning "Federated credential '$MAIN_CRED_NAME' already exists, deleting..."
        az ad app federated-credential delete --id "$APP_ID" --federated-credential-id "$MAIN_CRED_NAME" --yes
    fi

    az ad app federated-credential create --id "$APP_ID" --parameters "{
        \"name\": \"$MAIN_CRED_NAME\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/main\",
        \"audiences\": [\"api://AzureADTokenExchange\"]
    }" > /dev/null
    print_success "Created federated credential for main branch"

    # Develop branch credential
    print_info "Setting up federated credential for develop branch..."
    DEVELOP_CRED_NAME="github-actions-develop"
    if az ad app federated-credential show --id "$APP_ID" --federated-credential-id "$DEVELOP_CRED_NAME" &> /dev/null; then
        print_warning "Federated credential '$DEVELOP_CRED_NAME' already exists, deleting..."
        az ad app federated-credential delete --id "$APP_ID" --federated-credential-id "$DEVELOP_CRED_NAME" --yes
    fi

    az ad app federated-credential create --id "$APP_ID" --parameters "{
        \"name\": \"$DEVELOP_CRED_NAME\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/develop\",
        \"audiences\": [\"api://AzureADTokenExchange\"]
    }" > /dev/null
    print_success "Created federated credential for develop branch"

    # Pull request credential
    print_info "Setting up federated credential for pull requests..."
    PR_CRED_NAME="github-actions-pr"
    if az ad app federated-credential show --id "$APP_ID" --federated-credential-id "$PR_CRED_NAME" &> /dev/null; then
        print_warning "Federated credential '$PR_CRED_NAME' already exists, deleting..."
        az ad app federated-credential delete --id "$APP_ID" --federated-credential-id "$PR_CRED_NAME" --yes
    fi

    az ad app federated-credential create --id "$APP_ID" --parameters "{
        \"name\": \"$PR_CRED_NAME\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$REPO_OWNER/$REPO_NAME:pull_request\",
        \"audiences\": [\"api://AzureADTokenExchange\"]
    }" > /dev/null
    print_success "Created federated credential for pull requests"
}

assign_azure_permissions() {
    print_header "Assigning Azure Permissions"

    # Assign Contributor role at subscription level
    print_info "Assigning Contributor role at subscription level..."
    if az role assignment create \
        --assignee "$APP_ID" \
        --role "Contributor" \
        --scope "/subscriptions/$SUBSCRIPTION_ID" &> /dev/null; then
        print_success "Assigned Contributor role"
    else
        print_warning "Contributor role may already be assigned"
    fi

    # Assign additional roles if needed
    print_info "Assigning User Access Administrator role (for RBAC management)..."
    if az role assignment create \
        --assignee "$APP_ID" \
        --role "User Access Administrator" \
        --scope "/subscriptions/$SUBSCRIPTION_ID" &> /dev/null; then
        print_success "Assigned User Access Administrator role"
    else
        print_warning "User Access Administrator role may already be assigned"
    fi
}

configure_github_secrets() {
    print_header "Configuring GitHub Secrets"

    TENANT_ID=$(az account show --query tenantId -o tsv)

    print_info "Setting AZURE_CLIENT_ID..."
    echo "$APP_ID" | gh secret set AZURE_CLIENT_ID
    print_success "Set AZURE_CLIENT_ID"

    print_info "Setting AZURE_TENANT_ID..."
    echo "$TENANT_ID" | gh secret set AZURE_TENANT_ID
    print_success "Set AZURE_TENANT_ID"

    print_info "Setting AZURE_SUBSCRIPTION_ID..."
    echo "$SUBSCRIPTION_ID" | gh secret set AZURE_SUBSCRIPTION_ID
    print_success "Set AZURE_SUBSCRIPTION_ID"

    print_info "Setting AZURE_RESOURCE_GROUP..."
    echo "$RESOURCE_GROUP" | gh secret set AZURE_RESOURCE_GROUP
    print_success "Set AZURE_RESOURCE_GROUP"

    print_info "Setting AZURE_LOCATION..."
    echo "$LOCATION" | gh secret set AZURE_LOCATION
    print_success "Set AZURE_LOCATION"
}

print_summary() {
    print_header "Setup Complete!"

    echo -e "${GREEN}GitHub Actions OIDC configuration is complete.${NC}\n"
    echo -e "Configuration Details:"
    echo -e "  Repository:        $REPO_OWNER/$REPO_NAME"
    echo -e "  Azure AD App:      $APP_NAME"
    echo -e "  Application ID:    $APP_ID"
    echo -e "  Tenant ID:         $(az account show --query tenantId -o tsv)"
    echo -e "  Subscription:      $SUBSCRIPTION_NAME"
    echo -e "  Subscription ID:   $SUBSCRIPTION_ID"
    echo -e "  Resource Group:    $RESOURCE_GROUP"
    echo -e "  Location:          $LOCATION"
    echo -e "\nFederated Credentials Created:"
    echo -e "  ✓ Main branch:     repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/main"
    echo -e "  ✓ Develop branch:  repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/develop"
    echo -e "  ✓ Pull requests:   repo:$REPO_OWNER/$REPO_NAME:pull_request"
    echo -e "\nGitHub Secrets Configured:"
    echo -e "  ✓ AZURE_CLIENT_ID"
    echo -e "  ✓ AZURE_TENANT_ID"
    echo -e "  ✓ AZURE_SUBSCRIPTION_ID"
    echo -e "  ✓ AZURE_RESOURCE_GROUP"
    echo -e "  ✓ AZURE_LOCATION"
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo -e "  1. Review and commit the GitHub Actions workflow files"
    echo -e "  2. Push workflows to trigger deployments"
    echo -e "  3. Monitor workflow runs at: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "GitHub Actions OIDC Setup for py-azure-health"

    check_prerequisites
    create_azure_ad_app
    create_federated_credentials
    assign_azure_permissions
    configure_github_secrets
    print_summary
}

main "$@"
