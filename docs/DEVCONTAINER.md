# DevContainer Configuration

This directory contains the DevContainer configuration for the Python Azure Functions project. DevContainers provide a consistent, pre-configured development environment using Docker containers.

## What's Included

The DevContainer includes all required tools and dependencies:

- **Python 3.14** - Python runtime for Azure Functions
- **.NET 8 SDK** - Required by Azure Functions Core Tools
- **Azure Functions Core Tools v4** - Local function development and testing
- **Azure CLI** - Azure resource management (with Bicep)
- **Node.js 20 LTS** - Required by Azure Functions Core Tools
- **Git** - Version control
- **pre-commit** - Git hook framework for code quality
- **Azurite** - Azure Storage emulator (via VS Code extension)
- **Python Development Tools**:
  - black - Code formatter
  - flake8 - Linter
  - pytest - Testing framework
  - mypy - Static type checker

## Dev Container Features

This DevContainer uses [Dev Container Features](https://containers.dev/features) for dependency management:

- **common-utils** - Essential utilities (git, curl, wget, etc.)
- **python** - Python 3.14, pip, venv
- **node** - Node.js 20 LTS
- **azure-cli** - Azure CLI with Bicep
- **dotnet** - .NET 8 SDK
- **pre-commit** - Pre-commit framework
- **docker-in-docker** - Docker daemon for container operations
- **github-cli** - gh CLI tool
- **azd** - Azure Developer CLI
- **azure-functions-core-tools** - Azure Functions Core Tools v4

See [FEATURES.md](FEATURES.md) for detailed information about the feature migration.

## Pre-commit Hooks

This project uses [pre-commit](https://pre-commit.com/) to ensure code quality. Hooks are automatically installed during dev container setup and will run before each commit.

### Available Hooks:
- **Black** - Python code formatting
- **Flake8** - Python linting
- **Trailing whitespace removal**
- **End-of-file fixer**
- **YAML validation**
- **JSON validation**
- **Large file detection** (>500KB)
- **Merge conflict detection**
- **Private key detection**
- **GitLeaks** - Secret scanning

### Manual Usage:
```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run black --all-files

# Skip hooks for one commit
git commit --no-verify

# Update hooks to latest versions
pre-commit autoupdate
```

## VS Code Extensions

The following extensions are automatically installed:
- Azure Functions
- Python
- Pylance
- Black Formatter
- Flake8
- Azure CLI Tools
- Azure Resource Groups
- EditorConfig for VS Code
- Bicep
- Azurite

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Using the DevContainer

1. **Open in DevContainer**:
   - Open the repository in VS Code
   - Click the green button in the bottom-left corner
   - Select "Reopen in Container"
   - Wait for the container to build (first time takes a few minutes)

2. **Start Azurite** (Azure Storage Emulator):
   - Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
   - Run "Azurite: Start"
   - Or click the Azurite icon in the VS Code status bar

3. **Authenticate with Azure**:
   ```bash
   az login
   ```

4. **Configure Local Settings**:
   - Edit `src/local.settings.json` with your Azure subscription ID
   - The file is created automatically from the template

5. **Start the Function App**:
   ```bash
   func start --script-root src
   ```

6. **Test the Function**:
   ```bash
   curl "http://localhost:7071/api/hello?name=World"
   ```

## Features

### Port Forwarding

- **7071** - Azure Functions runtime (automatically forwarded)
- **10000** - Azurite Blob Storage
- **10001** - Azurite Queue Storage
- **10002** - Azurite Table Storage

### Azure Credentials

You'll need to authenticate with Azure inside the DevContainer using `az login`. Credentials are stored within the container and will persist between sessions.

### Python Virtual Environment

The DevContainer uses the system Python installation. If you prefer a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Customization

You can customize the DevContainer by editing:
- `devcontainer.json` - Main configuration file
- `Dockerfile` - Container image definition
- `post-create.sh` - Post-creation setup script

## Troubleshooting

### Container Build Fails

If the container fails to build:
1. Check Docker is running
2. Try "Rebuild Container" from the command palette
3. Check Docker logs for specific errors

### Python Dependencies Not Installing

If Python packages fail to install:
```bash
bash .devcontainer/post-create.sh
```

### Azure CLI Authentication

If you need to authenticate or re-authenticate:
```bash
az login
```

### Azurite Not Starting

If Azurite fails to start:
1. Check the Azurite extension is installed
2. Try starting manually via Command Palette: "Azurite: Start"
3. Check the output panel for Azurite logs

## Benefits

- **Consistency**: Everyone uses the same development environment
- **Quick Setup**: No manual installation of tools and dependencies
- **Isolation**: Development environment is isolated from your host system
- **Portability**: Works on Windows, macOS, and Linux

## Additional Resources

- [VS Code DevContainers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Azure Functions with DevContainers](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=python#development-container)
- [DevContainer Specification](https://containers.dev/)
