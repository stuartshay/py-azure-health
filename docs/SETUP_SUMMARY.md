# DevContainer Setup Summary

This document summarizes the DevContainer setup for the Python Azure Health Functions project, adapted from the PowerShell Azure Health project.

## What Was Created

### Core DevContainer Files

1. **`.devcontainer/devcontainer.json`**
   - Main configuration file
   - Defines 10+ Dev Container Features for tool installation
   - Configures VS Code extensions and settings
   - Sets up port forwarding for Functions and Azurite

2. **`.devcontainer/Dockerfile`**
   - Based on Python 3.11 slim image
   - Minimal configuration (most work done by Features)
   - Documents feature usage

3. **`.devcontainer/post-create.sh`**
   - Post-creation setup script
   - Installs Python dependencies
   - Configures pre-commit hooks
   - Creates local.settings.json from template
   - Sets up Azurite workspace directory

4. **`.devcontainer/README.md`**
   - Comprehensive DevContainer documentation
   - Getting started guide
   - Troubleshooting section

5. **`.devcontainer/FEATURES.md`**
   - Detailed documentation of all Dev Container Features
   - Benefits and configuration for each feature
   - Testing instructions

### Supporting Files

6. **`.pre-commit-config.yaml`**
   - Pre-commit hooks configuration
   - Python formatting (Black)
   - Python linting (Flake8)
   - Import sorting (isort)
   - Secret scanning (GitLeaks)
   - Standard file quality checks

7. **`.editorconfig`**
   - Editor configuration for consistent formatting
   - Python, JSON, YAML, Bicep, Shell scripts
   - 4 spaces for Python, 2 for JSON/YAML

8. **`src/local.settings.json.template`**
   - Template for local development settings
   - Configuration for Functions runtime
   - Azure subscription ID placeholder

9. **`QUICKSTART.md`**
   - Comprehensive quick start guide
   - Step-by-step setup instructions
   - Development workflow examples
   - Troubleshooting tips

10. **`README.md`** (Updated)
    - Project overview
    - Quick start section
    - Development and deployment guides
    - Configuration examples

11. **`.gitignore`** (Updated)
    - Added DevContainer entries
    - Added Azurite directory
    - Added pre-commit cache
    - Added Azure cost estimation directory

## Key Differences from PowerShell Project

### Runtime Differences

| Aspect | PowerShell Project | Python Project |
|--------|-------------------|----------------|
| **Base Image** | `mcr.microsoft.com/powershell:latest` | `python:3.11-slim-bookworm` |
| **Runtime** | PowerShell 7.4+ | Python 3.11 |
| **Package Manager** | PowerShell Gallery | pip |
| **Modules** | Az, Az.ResourceGraph, Az.Monitor, Pester, PSScriptAnalyzer | azure-functions, plus dev tools (black, flake8, pytest, mypy) |

### Tool Differences

| Tool | PowerShell Project | Python Project |
|------|-------------------|----------------|
| **Formatter** | PSScriptAnalyzer | Black |
| **Linter** | PSScriptAnalyzer | Flake8 |
| **Testing** | Pester | pytest |
| **Type Checking** | N/A | mypy |
| **Import Sorting** | N/A | isort |

### Shared Components

Both projects use the same Dev Container Features:
- ✅ common-utils (git, curl, wget, non-root user)
- ✅ python (Python 3.10/3.11)
- ✅ node (Node.js 20/24)
- ✅ azure-cli (with Bicep)
- ✅ dotnet (.NET 8 SDK)
- ✅ pre-commit
- ✅ docker-in-docker
- ✅ github-cli
- ✅ azd (Azure Developer CLI)
- ✅ azure-functions-core-tools

## Dev Container Features Explained

### What are Dev Container Features?

Dev Container Features are reusable, self-contained units of installation code that add specific tools or runtimes to a development container. They are:

- **Maintained by the community** - No need to maintain installation scripts
- **Version-controlled** - Pin to specific versions
- **Composable** - Mix and match features
- **Well-documented** - Available at https://containers.dev/features

### Benefits

1. **Faster builds** - Pre-compiled binaries and optimized installation
2. **Reliability** - Tested across many scenarios
3. **Maintainability** - Community handles updates
4. **Consistency** - Same features work across different base images
5. **Documentation** - Well-documented at containers.dev

### Example Feature Configuration

```json
"features": {
  "ghcr.io/devcontainers/features/python:1": {
    "version": "3.11",
    "installTools": true
  },
  "ghcr.io/devcontainers/features/azure-cli:1": {
    "version": "latest",
    "installBicep": true
  }
}
```

## Pre-commit Hooks

The project includes comprehensive pre-commit hooks:

### Python-Specific Hooks
- **Black** - Automatic code formatting (88 char line length)
- **Flake8** - Code linting and style checking
- **isort** - Import statement sorting

### General Hooks
- **Trailing whitespace** - Remove trailing whitespace
- **End-of-file fixer** - Ensure files end with newline
- **YAML/JSON validation** - Syntax checking
- **Large file detection** - Prevent committing files >500KB
- **GitLeaks** - Secret scanning
- **EditorConfig** - Enforce editor settings

## VS Code Extensions

Automatically installed extensions:

### Azure Extensions
- `ms-azuretools.vscode-azurefunctions` - Azure Functions
- `ms-vscode.azurecli` - Azure CLI Tools
- `ms-azuretools.vscode-azureresourcegroups` - Azure Resources
- `ms-azuretools.vscode-bicep` - Bicep

### Python Extensions
- `ms-python.python` - Python
- `ms-python.vscode-pylance` - Pylance (IntelliSense)
- `ms-python.black-formatter` - Black Formatter
- `ms-python.flake8` - Flake8

### Other Extensions
- `EditorConfig.EditorConfig` - EditorConfig
- `azurite.azurite` - Azurite Storage Emulator

## Port Forwarding

| Port | Service | Purpose |
|------|---------|---------|
| 7071 | Azure Functions | Function app runtime |
| 10000 | Azurite Blob | Blob storage emulator |
| 10001 | Azurite Queue | Queue storage emulator |
| 10002 | Azurite Table | Table storage emulator |

## Quick Start Workflow

1. **Open in DevContainer**
   - VS Code detects `.devcontainer/` configuration
   - Click "Reopen in Container"
   - First build takes 5-10 minutes

2. **Automatic Setup**
   - All tools installed via Features
   - post-create.sh runs automatically
   - Python dependencies installed
   - Pre-commit hooks configured

3. **Start Development**
   - Start Azurite (Command Palette or status bar)
   - Authenticate with Azure (`az login`)
   - Configure subscription ID in `local.settings.json`
   - Start Functions (`func start --script-root src`)

4. **Code Quality**
   - Pre-commit hooks run on every commit
   - Format with Black on save
   - Lint with Flake8
   - Test with pytest

## Testing the Setup

After the container builds, verify everything works:

```bash
# Check tool versions
python --version          # Python 3.11.x
func --version            # Azure Functions Core Tools 4.x
az version                # Azure CLI
pre-commit --version      # pre-commit 3.x

# Install dependencies
pip install -r requirements.txt

# Start Azurite
# Command Palette > "Azurite: Start"

# Start Functions
func start --script-root src

# Test function (in another terminal)
curl "http://localhost:7071/api/hello?name=World"
```

## Comparison with PowerShell Project

### Similarities
- ✅ Same DevContainer structure
- ✅ Same Dev Container Features (10+)
- ✅ Pre-commit hooks for code quality
- ✅ Azurite for local storage
- ✅ VS Code extensions for Azure
- ✅ Comprehensive documentation
- ✅ Quick start guides

### Differences
- 🔄 Python 3.11 instead of PowerShell 7.4
- 🔄 Black/Flake8/pytest instead of PSScriptAnalyzer/Pester
- 🔄 pip/requirements.txt instead of PowerShell Gallery
- 🔄 Python-specific VS Code extensions
- 🔄 Python-specific pre-commit hooks

### Architecture Alignment
Both projects follow the same patterns:
- DevContainer Features for tool installation
- Minimal Dockerfile (delegates to Features)
- post-create.sh for project-specific setup
- Comprehensive documentation
- Pre-commit hooks for quality
- Local development with Azurite

## Next Steps

1. **Test the DevContainer**
   - Open repository in VS Code
   - Reopen in Container
   - Wait for build to complete
   - Verify all tools are installed

2. **Configure Azure**
   - Run `az login`
   - Update `src/local.settings.json`
   - Set your subscription ID

3. **Start Development**
   - Start Azurite
   - Start Functions app
   - Test endpoints
   - Add new functions

4. **Customize (Optional)**
   - Add more VS Code extensions
   - Configure additional pre-commit hooks
   - Add Python development tools
   - Update Python version in Features

## References

- **PowerShell Project**: https://github.com/stuartshay/pwsh-azure-health
- **Dev Container Features**: https://containers.dev/features
- **Azure Functions Python**: https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python
- **VS Code DevContainers**: https://code.visualstudio.com/docs/devcontainers/containers

## Maintenance

### Updating Features

Edit `.devcontainer/devcontainer.json`:

```json
"features": {
  "ghcr.io/devcontainers/features/python:1": {
    "version": "3.12"  // Update Python version
  }
}
```

### Updating Pre-commit Hooks

```bash
# Update to latest versions
pre-commit autoupdate

# Test updates
pre-commit run --all-files
```

### Updating Python Dependencies

```bash
# Update requirements.txt
pip install --upgrade -r requirements.txt
pip freeze > requirements.txt
```

