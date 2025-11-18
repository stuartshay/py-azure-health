#!/bin/bash

# Azure Functions Python Project Setup Script
# This script sets up the Python virtual environment and installs dependencies

set -e

echo "=========================================="
echo "Azure Functions Python Project Setup"
echo "=========================================="

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "Found Python version: $PYTHON_VERSION"

# Create virtual environment
echo ""
echo "Creating Python virtual environment..."
if [ -d ".venv" ]; then
    echo "Virtual environment already exists. Removing old environment..."
    rm -rf .venv
fi

python3 -m venv .venv
echo "Virtual environment created successfully."

# Activate virtual environment
echo ""
echo "Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo ""
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo ""
echo "Installing Azure Functions dependencies..."
pip install -r requirements.txt

echo ""
echo "=========================================="
echo "Setup completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Activate the virtual environment:"
echo "   source .venv/bin/activate"
echo ""
echo "2. Install Azure Functions Core Tools if not already installed:"
echo "   https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local"
echo ""
echo "3. Start the function app locally:"
echo "   cd src && func start"
echo ""
echo "4. Test the HTTP trigger function:"
echo "   curl http://localhost:7071/api/hello?name=YourName"
echo ""
