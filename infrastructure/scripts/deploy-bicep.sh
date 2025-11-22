#!/bin/bash

################################################################################
# Bicep Deployment Script
#
# This script deploys Azure infrastructure using Bicep templates.
#
# Usage:
#   ./deploy-bicep.sh [environment] [action]
#
# Arguments:
#   environment - dev, staging, or prod (default: dev)
#   action      - deploy, validate, or what-if (default: deploy)
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
# YELLOW='\033[1;33m'  # Unused, keeping for future use
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
ENVIRONMENT="${1:-dev}"
ACTION="${2:-deploy}"
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-rg-azure-health-dev}"
LOCATION="${AZURE_LOCATION:-eastus}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_DIR="$(cd "$SCRIPT_DIR/../bicep" && pwd)"

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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"

    if ! command -v az &> /dev/null; then
        print_error "Azure CLI not found"
        exit 1
    fi
    print_success "Azure CLI found"

    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure"
        exit 1
    fi
    print_success "Logged in to Azure"
}

ensure_resource_group() {
    print_header "Ensuring Resource Group"

    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        print_info "Resource group $RESOURCE_GROUP already exists"
    else
        print_info "Creating resource group $RESOURCE_GROUP..."
        az group create \
            --name "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --tags environment="$ENVIRONMENT" application=py-azure-health
        print_success "Resource group created"
    fi
}

validate_templates() {
    print_header "Validating Bicep Templates"

    print_info "Validating main.bicep..."
    az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$BICEP_DIR/main.bicep" \
        --parameters environment="$ENVIRONMENT" \
        --output none

    print_success "Templates validated successfully"
}

what_if_analysis() {
    print_header "Running What-If Analysis"

    print_info "Analyzing changes..."
    az deployment group what-if \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$BICEP_DIR/main.bicep" \
        --parameters environment="$ENVIRONMENT" \
        --result-format FullResourcePayloads
}

deploy_infrastructure() {
    print_header "Deploying Infrastructure"

    print_info "Starting deployment..."
    DEPLOYMENT_OUTPUT=$(az deployment group create \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$BICEP_DIR/main.bicep" \
        --parameters environment="$ENVIRONMENT" \
        --query 'properties.outputs' \
        --output json)

    print_success "Deployment completed"

    # Display outputs
    print_header "Deployment Outputs"
    echo "$DEPLOYMENT_OUTPUT" | jq '.'

    # Extract key values
    FUNCTION_APP_NAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.functionAppName.value')
    STORAGE_ACCOUNT=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.storageAccountName.value')

    print_success "Function App: $FUNCTION_APP_NAME"
    print_success "Storage Account: $STORAGE_ACCOUNT"
}

main() {
    print_header "Bicep Deployment Script"
    echo "Environment: $ENVIRONMENT"
    echo "Action: $ACTION"
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Location: $LOCATION"

    check_prerequisites

    case "$ACTION" in
        validate)
            validate_templates
            ;;
        what-if)
            ensure_resource_group
            what_if_analysis
            ;;
        deploy)
            ensure_resource_group
            validate_templates
            deploy_infrastructure
            ;;
        *)
            print_error "Invalid action: $ACTION"
            echo "Valid actions: deploy, validate, what-if"
            exit 1
            ;;
    esac

    print_success "Action completed successfully"
}

main "$@"
