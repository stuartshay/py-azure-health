# Python Azure Health Functions

[![Infrastructure Deploy](https://github.com/stuartshay/py-azure-health/actions/workflows/infrastructure-deploy.yml/badge.svg)](https://github.com/stuartshay/py-azure-health/actions/workflows/infrastructure-deploy.yml)


A Python-based Azure Functions project for health monitoring and API endpoints.

## Features

- **HTTP Trigger Functions** - REST API endpoints
- **Timer Trigger Functions** - Scheduled background tasks
- **Azure Storage Integration** - Blob, Queue, and Table storage
- **Application Insights** - Monitoring and telemetry
- **DevContainer Support** - Pre-configured development environment

## Quick Start

The fastest way to get started is using the pre-configured DevContainer:

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop) and [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open this repository in VS Code
3. Click "Reopen in Container" when prompted
4. Wait for the container to build (first time only)
5. Start Azurite: Command Palette > "Azurite: Start"
6. Authenticate with Azure: `az login`
7. Update `src/local.settings.json` with your subscription ID
8. Start the function: `func start --script-root src`

All prerequisites (Python 3.14, Azure Functions Core Tools, Azure CLI, and development tools) are automatically installed! See [Quick Start Guide](docs/QUICKSTART.md) for detailed instructions.

## Prerequisites (Without DevContainer)

- Python 3.14 or later
- [Azure Functions Core Tools v4](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Visual Studio Code](https://code.visualstudio.com/) (recommended)

## Project Structure

```text
py-azure-health/
├── .devcontainer/          # DevContainer configuration
│   ├── devcontainer.json   # Container configuration
│   ├── Dockerfile          # Container image
│   └── post-create.sh      # Setup script
├── docs/                   # Project documentation
│   ├── README.md           # Documentation index
│   ├── QUICKSTART.md       # Quick start guide
│   ├── DEVCONTAINER.md     # DevContainer guide
│   ├── FEATURES.md         # Features documentation
│   └── SETUP_SUMMARY.md    # Complete setup summary
├── scripts/                # Helper scripts
│   ├── test-function.sh    # Test script
│   ├── start-function.sh   # Start script
│   └── stop-function.sh    # Stop script
├── src/                    # Function app source
│   ├── function_app.py     # Main function definitions
│   ├── host.json           # Function host configuration
│   └── local.settings.json # Local development settings
├── requirements.txt        # Python dependencies
├── .pre-commit-config.yaml # Pre-commit hooks configuration
├── .editorconfig           # Editor configuration
├── .gitignore              # Git ignore patterns
├── QUICKSTART.md           # Quick start guide
└── README.md               # This file
```

## Development

### Local Development

```bash
# Start Azurite (Azure Storage Emulator)
# In VS Code: Command Palette > "Azurite: Start"

# Authenticate with Azure
az login

# Start the function app
func start --script-root src

# Test the function
curl "http://localhost:7071/api/hello?name=World"
```

### Code Quality

The project uses pre-commit hooks for code quality:

```bash
# Run all hooks
pre-commit run --all-files

# Format code
black src/

# Lint code
flake8 src/

# Type check
mypy src/

# Run tests
pytest
```

### Adding New Functions

#### HTTP Trigger

```python
@app.route(route="myfunction")
def my_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Processing request...')
    return func.HttpResponse("Success!", status_code=200)
```

#### Timer Trigger

```python
@app.schedule(schedule="0 */5 * * * *", arg_name="myTimer", run_on_startup=False)
def timer_function(myTimer: func.TimerRequest) -> None:
    logging.info('Timer trigger function executed.')
```

## Deployment

The project uses **GitHub Actions** for automated CI/CD with secure OIDC authentication (no secrets stored!).

### Initial Setup (One-Time)

Configure GitHub Actions to deploy to Azure:

```bash
cd infrastructure/scripts
chmod +x *.sh
./setup-github-actions.sh
```

This creates Azure AD application, configures federated credentials, and sets GitHub secrets automatically.

**Verify setup:**
```bash
./validate-github-setup.sh
```

### Deployment Options

#### Option 1: GitHub Actions (Recommended)

**Infrastructure Deployment:**
1. Go to **Actions** tab → **Infrastructure Deploy**
2. Select environment (dev/staging/prod)
3. Type "deploy" to confirm
4. Monitor deployment progress

**Function Deployment:**
- **Automatic:** Push to `main` or `develop` with changes in `src/**`
- **Manual:** Actions tab → **Function Deploy** → Run workflow

**Preview Changes (What-If):**
- Pull requests automatically show infrastructure changes
- Manual: Actions tab → **Infrastructure What-If**

**Available Workflows:**
- ✅ **infrastructure-deploy.yml** - Deploy Azure resources
- ✅ **infrastructure-destroy.yml** - Remove resources
- ✅ **infrastructure-whatif.yml** - Preview changes
- ✅ **function-deploy.yml** - Deploy function code
- ✅ **lint-and-test.yml** - Quality checks

#### Option 2: Local Scripts

```bash
# Deploy infrastructure
cd infrastructure/scripts
./deploy-bicep.sh dev deploy

# Preview changes
./deploy-bicep.sh dev what-if

# Validate templates
./deploy-bicep.sh dev validate

# View existing resources
./get-existing-resources.sh
```

#### Option 3: Manual Deployment

```bash
# Deploy infrastructure
az deployment group create \
  --resource-group rg-azure-health-dev \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev

# Deploy function code
func azure functionapp publish <function-app-name>
```

### Infrastructure Components

**Deployed Resources:**
- Function App (Python 3.11)
- Storage Account
- Application Insights
- Log Analytics Workspace
- Uses existing App Service Plan: `azurehealth-plan-dev`

**See detailed documentation:** [infrastructure/README.md](infrastructure/README.md)

## Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# View coverage report
open htmlcov/index.html
```

## Configuration

### local.settings.json

```json
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
```

## DevContainer

The DevContainer provides a consistent development environment with:

- Python 3.14
- Azure Functions Core Tools v4
- Azure CLI with Bicep
- Node.js 20 LTS
- .NET 8 SDK
- Pre-commit hooks
- Python development tools (black, flake8, pytest, mypy)
- Azurite (Azure Storage Emulator)

See [.devcontainer/README.md](.devcontainer/README.md) for details.

## Troubleshooting

### Container Build Fails

```bash
# Rebuild container
Ctrl+Shift+P > "Dev Containers: Rebuild Container"
```

### Functions Won't Start

```bash
# Check version
func --version

# Clear cache
rm -rf .azurite/*
func start --script-root src
```

### Azurite Issues

```bash
# Check logs: View > Output > "Azurite"
# Clean: Ctrl+Shift+P > "Azurite: Clean"
# Restart: Ctrl+Shift+P > "Azurite: Start"
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

MIT License

## Documentation

Comprehensive documentation is available in the [docs/](docs/) folder:

- **[Quick Start Guide](docs/QUICKSTART.md)** - Get started quickly
- **[DevContainer Guide](docs/DEVCONTAINER.md)** - Development environment setup
- **[Dev Container Features](docs/FEATURES.md)** - Feature explanations
- **[Setup Summary](docs/SETUP_SUMMARY.md)** - Complete setup details

## Resources

- [Azure Functions Python Developer Guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python)
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azurite Storage Emulator](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite)
- [VS Code DevContainers](https://code.visualstudio.com/docs/devcontainers/containers)
