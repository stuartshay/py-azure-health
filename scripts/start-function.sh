#!/bin/bash

# Azure Functions Launcher Script
# Starts the Azure Functions host for local development

set -e

# Get the project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "Starting Azure Functions"
echo "=========================================="

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Error: Virtual environment not found."
    echo "Please run ./install.sh first to set up the project."
    exit 1
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Check if Azure Functions Core Tools is installed
if ! command -v func &> /dev/null; then
    echo ""
    echo "Error: Azure Functions Core Tools (func) is not installed."
    echo ""
    echo "Install it using one of the following methods:"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg"
    echo "  sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg"
    echo "  sudo sh -c 'echo \"deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main\" > /etc/apt/sources.list.d/dotnetdev.list'"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install azure-functions-core-tools-4"
    echo ""
    echo "For macOS:"
    echo "  brew tap azure/functions"
    echo "  brew install azure-functions-core-tools@4"
    echo ""
    echo "For more information, visit:"
    echo "  https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local"
    exit 1
fi

FUNC_VERSION=$(func --version)
echo "Azure Functions Core Tools version: $FUNC_VERSION"

# Navigate to src directory and start the function
echo ""
echo "Starting Azure Functions host..."
echo "Function app location: $PROJECT_ROOT/src"
echo ""
cd src
func start

# Deactivate virtual environment on exit
deactivate
