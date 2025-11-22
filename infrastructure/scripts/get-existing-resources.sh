#!/bin/bash

################################################################################
# Get Existing Azure Resources
#
# This script retrieves information about existing Azure resources.
#
# Usage:
#   ./get-existing-resources.sh
################################################################################

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-rg-azure-health-dev}"
# SHARED_RG="rg-azure-health-shared"  # Unused, keeping for future use

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

check_login() {
    if ! az account show &> /dev/null; then
        echo "Not logged in to Azure. Please run: az login"
        exit 1
    fi
    print_success "Logged in to Azure"
}

get_subscription_info() {
    print_header "Subscription Information"

    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    TENANT_ID=$(az account show --query tenantId -o tsv)

    echo "Subscription ID:   $SUBSCRIPTION_ID"
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Tenant ID:         $TENANT_ID"
}

list_resource_groups() {
    print_header "Resource Groups"

    echo "Checking for py-azure-health resource groups..."
    az group list \
        --query "[?contains(name, 'azure-health')].{Name:name, Location:location, State:properties.provisioningState}" \
        --output table
}

get_app_service_plans() {
    print_header "App Service Plans"

    echo "Looking for existing App Service Plans..."
    az appservice plan list \
        --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, Sku:sku.name, Kind:kind}" \
        --output table
}

get_function_apps() {
    print_header "Function Apps"

    echo "Looking for existing Function Apps..."
    az functionapp list \
        --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, State:state, DefaultHostName:defaultHostName}" \
        --output table
}

get_storage_accounts() {
    print_header "Storage Accounts"

    echo "Looking for existing Storage Accounts..."
    az storage account list \
        --query "[?contains(name, 'azurehealth')].{Name:name, ResourceGroup:resourceGroup, Location:location, Sku:sku.name}" \
        --output table
}

get_app_insights() {
    print_header "Application Insights"

    echo "Looking for existing Application Insights..."
    az monitor app-insights component list \
        --query "[?contains(name, 'azure-health')].{Name:name, ResourceGroup:resourceGroup, Location:location, InstrumentationKey:instrumentationKey}" \
        --output table
}

get_deployments() {
    print_header "Recent Deployments"

    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        echo "Deployments in $RESOURCE_GROUP:"
        az deployment group list \
            --resource-group "$RESOURCE_GROUP" \
            --query "[].{Name:name, State:properties.provisioningState, Timestamp:properties.timestamp}" \
            --output table
    else
        echo "Resource group $RESOURCE_GROUP does not exist"
    fi
}

main() {
    print_header "Azure Resources for py-azure-health"

    check_login
    get_subscription_info
    list_resource_groups
    get_app_service_plans
    get_function_apps
    get_storage_accounts
    get_app_insights
    get_deployments

    print_success "Resource scan complete"
}

main "$@"
