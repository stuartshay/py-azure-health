#!/bin/bash
# Exit on error for critical failures, but allow some steps to fail gracefully
set -e

echo "=================================="
echo "Setting up DevContainer environment..."
echo "=================================="

# Note: Base tools installed via Dev Container Features:
# - common-utils: git, curl, wget, sudo, non-root user
# - python: Python 3.14, pip, venv
# - node: Node.js 20 (via nvm)
# - azure-cli: Azure CLI with Bicep
# - dotnet: .NET 8 SDK
# - docker-in-docker: Docker daemon
# - github-cli: gh CLI tool
# - pre-commit: pre-commit framework
# - azure-functions-core-tools: Azure Functions Core Tools v4
# - azd: Azure Developer CLI
# Note: Azurite is installed via VS Code extension (azurite.azurite)

# Wait for features to complete initialization
echo "Waiting for feature installation to complete..."
sleep 5

# Verify critical tools
echo "Verifying installed tools..."

if command -v python &> /dev/null; then
    echo "✅ Python: $(python --version)"
else
    echo "⚠️  Python not found"
fi

if command -v pip &> /dev/null; then
    echo "✅ pip: $(pip --version)"
else
    echo "⚠️  pip not found"
fi

if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "⚠️  Node.js not found"
fi

if command -v npm &> /dev/null; then
    echo "✅ npm: $(npm --version)"
else
    echo "⚠️  npm not found"
fi

if command -v func &> /dev/null; then
    echo "✅ Azure Functions Core Tools: $(func --version)"
else
    echo "⚠️  Azure Functions Core Tools not found"
fi

if command -v az &> /dev/null; then
    echo "✅ Azure CLI: $(az version --query \"azure-cli\" -o tsv 2>/dev/null || echo 'installed')"
else
    echo "⚠️  Azure CLI not found"
fi

if command -v azd &> /dev/null; then
    echo "✅ Azure Developer CLI: $(azd version 2>/dev/null || echo 'installed')"
else
    echo "⚠️  Azure Developer CLI not found"
fi

if command -v dotnet &> /dev/null; then
    echo "✅ .NET SDK: $(dotnet --version)"
else
    echo "⚠️  .NET SDK not found"
fi

if command -v pre-commit &> /dev/null; then
    echo "✅ Pre-commit: $(pre-commit --version)"
else
    echo "⚠️  Pre-commit not found"
fi

# Verify Bicep installation (installed via Azure CLI feature)
if command -v bicep &> /dev/null; then
    echo "✅ Bicep CLI: $(bicep --version)"
else
    echo "⚠️  Bicep CLI not found, installing manually..."
    mkdir -p "$HOME/.azure/bin"
    curl -sSL -o "$HOME/.azure/bin/bicep" https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
    chmod +x "$HOME/.azure/bin/bicep"
    export PATH="$PATH:$HOME/.azure/bin"
    if [ -x "$HOME/.azure/bin/bicep" ]; then
        echo "✅ Bicep CLI: $("$HOME"/.azure/bin/bicep --version)"
    fi
fi

# Install azure-cost-cli for cost analysis
echo "Installing azure-cost-cli..."
if command -v dotnet &> /dev/null; then
    if dotnet tool install --global azure-cost-cli --version 0.52.0 2>/dev/null || dotnet tool update --global azure-cost-cli --version 0.52.0 2>/dev/null; then
        echo "✅ azure-cost-cli installed successfully"
        # Ensure dotnet tools are in PATH
        export PATH="$PATH:$HOME/.dotnet/tools"
        if command -v azure-cost-cli &> /dev/null; then
            echo "✅ azure-cost-cli: $(azure-cost-cli --version 2>/dev/null || echo 'installed')"
        fi
    else
        echo "⚠️  azure-cost-cli installation may have failed"
    fi
else
    echo "⚠️  .NET SDK not found, skipping azure-cost-cli installation"
fi

# Create Azurite workspace directory
echo "Creating Azurite workspace directory..."
WORKSPACE_DIR="${WORKSPACE_DIR:-$(pwd)}"
mkdir -p "${WORKSPACE_DIR}/.azurite"
echo "✅ Azurite directory ready at ${WORKSPACE_DIR}/.azurite"
echo "ℹ️  Start Azurite via Command Palette: 'Azurite: Start' or use the status bar"

# Upgrade pip and install common Python development tools
echo "Upgrading pip and installing Python development tools..."
python -m pip install --upgrade pip setuptools wheel

# Install project Python dependencies
echo "Installing project Python dependencies..."
if [ -f "${WORKSPACE_DIR}/requirements.txt" ]; then
    pip install -r "${WORKSPACE_DIR}/requirements.txt"
    echo "✅ Installed requirements.txt dependencies"
else
    echo "⚠️  requirements.txt not found, skipping"
fi

# Install Python development/testing tools
echo "Installing Python development tools..."
pip install --no-cache-dir \
    black \
    flake8 \
    pytest \
    pytest-cov \
    mypy

echo "✅ Python development tools installed"

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
if [ -f "${WORKSPACE_DIR}/.pre-commit-config.yaml" ]; then
    # Set pre-commit cache to workspace directory
    export PRE_COMMIT_HOME="${WORKSPACE_DIR}/.pre-commit-cache"
    mkdir -p "$PRE_COMMIT_HOME"

    # Install hooks
    pre-commit install
    pre-commit install --hook-type pre-push

    # Run hooks on all files to cache them
    echo "Running pre-commit hooks on all files (this may take a moment)..."
    pre-commit run --all-files || true

    echo "✅ Pre-commit hooks installed"
else
    echo "⚠️  .pre-commit-config.yaml not found, skipping pre-commit setup"
fi

# Create local.settings.json if it doesn't exist
if [ ! -f "src/local.settings.json" ]; then
    if [ -f "src/local.settings.json.template" ]; then
        echo "Creating local.settings.json from template..."
        cp src/local.settings.json.template src/local.settings.json
        echo "✅ Created src/local.settings.json - Please update with your Azure subscription ID"
    else
        echo "Creating default local.settings.json..."
        cat > src/local.settings.json <<EOF
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.14",
    "AZURE_SUBSCRIPTION_ID": "your-subscription-id-here",
    "APPLICATIONINSIGHTS_CONNECTION_STRING": ""
  }
}
EOF
        echo "✅ Created default src/local.settings.json - Please update with your Azure subscription ID"
    fi
else
    echo "✅ src/local.settings.json already exists"
fi

echo "=================================="
echo "DevContainer setup complete! 🎉"
echo "=================================="
echo ""
echo "Pre-commit hooks are installed and will run automatically on commits."
echo "To skip pre-commit hooks: git commit --no-verify"
echo "To run hooks manually: pre-commit run --all-files"
echo ""
echo "Next steps:"
echo "1. Start Azurite: Command Palette > 'Azurite: Start' or click status bar"
echo "2. Update src/local.settings.json with your Azure subscription ID"
echo "3. Authenticate with Azure: az login"
echo "4. Start the function app: func start --script-root src"
echo ""
