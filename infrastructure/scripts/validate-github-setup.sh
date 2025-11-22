#!/bin/bash

################################################################################
# Validate GitHub Actions Setup
#
# This script validates that GitHub Actions is properly configured for
# deploying to Azure using OIDC authentication.
#
# Usage:
#   ./validate-github-setup.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_NAME="py-azure-health-github-actions"
ERRORS=0
WARNINGS=0

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
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_azure_cli() {
    print_header "Checking Azure CLI"

    if ! command -v az &> /dev/null; then
        print_error "Azure CLI not found"
        return 1
    fi
    print_success "Azure CLI installed"

    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure"
        return 1
    fi
    print_success "Logged in to Azure"
}

check_github_cli() {
    print_header "Checking GitHub CLI"

    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not found"
        return 1
    fi
    print_success "GitHub CLI installed"

    if ! gh auth status &> /dev/null; then
        print_error "Not logged in to GitHub"
        return 1
    fi
    print_success "Logged in to GitHub"
}

check_repository() {
    print_header "Checking Repository"

    if ! REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null); then
        print_error "Not in a GitHub repository"
        return 1
    fi
    print_success "Repository: $REPO_INFO"
}

check_azure_ad_app() {
    print_header "Checking Azure AD Application"

    if ! APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv 2>/dev/null); then
        print_error "Azure AD app '$APP_NAME' not found"
        print_info "Run ./setup-github-actions.sh to create it"
        return 1
    fi

    if [ -z "$APP_ID" ]; then
        print_error "Azure AD app '$APP_NAME' not found"
        return 1
    fi

    print_success "Azure AD App ID: $APP_ID"

    # Check service principal
    if SP_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --query "[0].id" -o tsv 2>/dev/null); then
        if [ -n "$SP_ID" ]; then
            print_success "Service Principal exists: $SP_ID"
        else
            print_error "Service Principal not found for app"
        fi
    fi
}

check_federated_credentials() {
    print_header "Checking Federated Credentials"

    APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv 2>/dev/null)

    if [ -z "$APP_ID" ]; then
        print_error "Cannot check federated credentials - app not found"
        return 1
    fi

    CREDS=$(az ad app federated-credential list --id "$APP_ID" --query "[].name" -o tsv)

    if echo "$CREDS" | grep -q "github-actions-main"; then
        print_success "Main branch credential exists"
    else
        print_warning "Main branch credential not found"
    fi

    if echo "$CREDS" | grep -q "github-actions-develop"; then
        print_success "Develop branch credential exists"
    else
        print_warning "Develop branch credential not found"
    fi

    if echo "$CREDS" | grep -q "github-actions-pr"; then
        print_success "Pull request credential exists"
    else
        print_warning "Pull request credential not found"
    fi
}

check_azure_permissions() {
    print_header "Checking Azure Permissions"

    APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv 2>/dev/null)
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)

    if [ -z "$APP_ID" ]; then
        print_error "Cannot check permissions - app not found"
        return 1
    fi

    # Check role assignments
    ROLES=$(az role assignment list \
        --assignee "$APP_ID" \
        --scope "/subscriptions/$SUBSCRIPTION_ID" \
        --query "[].roleDefinitionName" -o tsv)

    if echo "$ROLES" | grep -q "Contributor"; then
        print_success "Contributor role assigned"
    else
        print_warning "Contributor role not assigned"
    fi

    if echo "$ROLES" | grep -q "User Access Administrator"; then
        print_success "User Access Administrator role assigned"
    else
        print_warning "User Access Administrator role not assigned"
    fi
}

check_github_secrets() {
    print_header "Checking GitHub Secrets"

    SECRETS=$(gh secret list --json name -q '.[].name' 2>/dev/null || echo "")

    if echo "$SECRETS" | grep -q "AZURE_CLIENT_ID"; then
        print_success "AZURE_CLIENT_ID secret exists"
    else
        print_error "AZURE_CLIENT_ID secret not found"
    fi

    if echo "$SECRETS" | grep -q "AZURE_TENANT_ID"; then
        print_success "AZURE_TENANT_ID secret exists"
    else
        print_error "AZURE_TENANT_ID secret not found"
    fi

    if echo "$SECRETS" | grep -q "AZURE_SUBSCRIPTION_ID"; then
        print_success "AZURE_SUBSCRIPTION_ID secret exists"
    else
        print_error "AZURE_SUBSCRIPTION_ID secret not found"
    fi

    if echo "$SECRETS" | grep -q "AZURE_RESOURCE_GROUP"; then
        print_success "AZURE_RESOURCE_GROUP secret exists"
    else
        print_error "AZURE_RESOURCE_GROUP secret not found"
    fi

    if echo "$SECRETS" | grep -q "AZURE_LOCATION"; then
        print_success "AZURE_LOCATION secret exists"
    else
        print_error "AZURE_LOCATION secret not found"
    fi
}

check_workflow_files() {
    print_header "Checking Workflow Files"

    WORKFLOWS=(
        ".github/workflows/infrastructure-deploy.yml"
        ".github/workflows/infrastructure-destroy.yml"
        ".github/workflows/infrastructure-whatif.yml"
        ".github/workflows/function-deploy.yml"
        ".github/workflows/lint-and-test.yml"
    )

    for workflow in "${WORKFLOWS[@]}"; do
        if [ -f "$workflow" ]; then
            print_success "$(basename "$workflow") exists"
        else
            print_warning "$(basename "$workflow") not found"
        fi
    done
}

print_summary() {
    print_header "Validation Summary"

    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        print_success "All checks passed! GitHub Actions is ready to use."
    elif [ $ERRORS -eq 0 ]; then
        echo -e "${YELLOW}Validation completed with $WARNINGS warning(s)${NC}"
        echo "Your setup should work, but review warnings above."
    else
        echo -e "${RED}Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
        echo "Please fix the errors above before using GitHub Actions."
        return 1
    fi
}

main() {
    print_header "GitHub Actions Setup Validation"

    check_azure_cli || true
    check_github_cli || true
    check_repository || true
    check_azure_ad_app || true
    check_federated_credentials || true
    check_azure_permissions || true
    check_github_secrets || true
    check_workflow_files || true

    echo ""
    print_summary

    if [ $ERRORS -gt 0 ]; then
        exit 1
    fi
}

main "$@"
