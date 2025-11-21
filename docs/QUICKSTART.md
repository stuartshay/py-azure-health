# Quick Start Guide - Python Azure Health Functions

This guide will help you get started with the Python Azure Health Functions project using the DevContainer.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Quick Setup (5 minutes)

### 1. Open in DevContainer

1. Open this repository in VS Code
2. Click the green button in the bottom-left corner
3. Select "Reopen in Container"
4. Wait for the container to build (first time takes 5-10 minutes)

All tools are automatically installed:
### What's Included

- ✅ Python 3.14
- ✅ Azure Functions Core Tools v4
- ✅ Azure CLI with Bicep
- ✅ Node.js 20 LTS
- ✅ .NET 8 SDK
- ✅ Pre-commit hooks
- ✅ Python development tools (black, flake8, pytest, mypy)

### 2. Start Azurite (Azure Storage Emulator)

Option 1: Command Palette
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
- Type "Azurite: Start"
- Press Enter

Option 2: Status Bar
- Click the "Azurite" button in the VS Code status bar

### 3. Configure Azure Subscription

Edit `src/local.settings.json`:
```json
{
  "Values": {
    "AZURE_SUBSCRIPTION_ID": "your-subscription-id-here"
  }
}
```

### 4. Authenticate with Azure

```bash
az login
```

### 5. Start the Function App

```bash
func start --script-root src
```

### 6. Test the Function

Open a new terminal and run:

```bash
# Test the hello function
curl "http://localhost:7071/api/hello?name=World"

# Expected response:
# Hello, World! This HTTP triggered function executed successfully.
```

## Using the Test Script

The project includes a test script for convenience:

```bash
# Test with default name
./scripts/test-function.sh

# Test with custom name
./scripts/test-function.sh --name "Stuart"

# Test with JSON request body
curl -X POST http://localhost:7071/api/hello \
  -H "Content-Type: application/json" \
  -d '{"name": "Azure"}'
```

## Development Workflow

### Code Formatting

Code is automatically formatted on save with Black. You can also run manually:

```bash
# Format all Python files
black src/

# Format specific file
black src/function_app.py
```

### Linting

```bash
# Lint all Python files
flake8 src/

# Lint specific file
flake8 src/function_app.py
```

### Type Checking

```bash
# Type check all files
mypy src/

# Type check specific file
mypy src/function_app.py
```

### Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# View coverage report
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
```

### Pre-commit Hooks

Pre-commit hooks run automatically before each commit. To run manually:

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run black --all-files

# Skip hooks for one commit (use sparingly!)
git commit --no-verify
```

## Adding New Functions

### HTTP Trigger Function

Edit `src/function_app.py` and add a new route:

```python
@app.route(route="myfunction")
def my_function(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Processing request...')
    
    # Your logic here
    
    return func.HttpResponse(
        "Success!",
        status_code=200
    )
```

### Timer Trigger Function

```python
@app.schedule(schedule="0 */5 * * * *", arg_name="myTimer", run_on_startup=False)
def timer_function(myTimer: func.TimerRequest) -> None:
    logging.info('Timer trigger function executed.')
    
    # Your logic here
```

## Deployment

### Deploy to Azure

```bash
# Deploy function code
func azure functionapp publish <function-app-name>

# Or use Azure CLI
az functionapp deployment source config-zip \
  -g <resource-group> \
  -n <function-app-name> \
  --src <zip-file>
```

### Infrastructure as Code

Use Bicep templates to deploy infrastructure:

```bash
# Create resource group
az group create --name rg-health-dev --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group rg-health-dev \
  --template-file infrastructure/main.bicep \
  --parameters environment=dev
```

## Troubleshooting

### Container Build Fails

```bash
# Rebuild container
Ctrl+Shift+P > "Dev Containers: Rebuild Container"
```

### Azurite Won't Start

```bash
# Check Azurite logs
View > Output > Select "Azurite" from dropdown

# Restart Azurite
Ctrl+Shift+P > "Azurite: Clean" then "Azurite: Start"
```

### Functions Won't Start

```bash
# Check Azure Functions Core Tools
func --version

# Clear cache and restart
rm -rf .azurite/*
func start --script-root src
```

### Python Dependencies Missing

```bash
# Reinstall dependencies
pip install -r requirements.txt

# Or run post-create script
bash .devcontainer/post-create.sh
```

## Next Steps

1. **Read the Documentation**
   - [DevContainer README](.devcontainer/README.md)
   - [Features Documentation](.devcontainer/FEATURES.md)

2. **Explore Azure Functions**
   - [Azure Functions Python Developer Guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python)
   - [Python V2 Programming Model](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python)

3. **Deploy to Azure**
   - Use Bicep templates in `infrastructure/`
   - Set up GitHub Actions for CI/CD
   - Configure monitoring with Application Insights

4. **Add More Functionality**
   - Add timer triggers for scheduled tasks
   - Integrate with Azure services (Storage, Cosmos DB, etc.)
   - Add authentication and authorization

## Useful Commands

```bash
# Azure Functions
func start --script-root src                 # Start function app
func new --template "HTTP trigger"           # Create new function
func azure functionapp list-functions <name> # List deployed functions

# Azure CLI
az login                                     # Login to Azure
az account list --output table               # List subscriptions
az functionapp list --output table           # List function apps

# Python
python --version                             # Check Python version
pip list                                     # List installed packages
pip install -r requirements.txt              # Install dependencies

# Pre-commit
pre-commit run --all-files                   # Run all hooks
pre-commit autoupdate                        # Update hook versions
pre-commit install                           # Install hooks

# Docker
docker ps                                    # List running containers
docker images                                # List images
docker logs <container-id>                   # View container logs
```

## Resources

- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Python Developer Guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python)
- [Azurite Documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite)
- [VS Code DevContainers](https://code.visualstudio.com/docs/devcontainers/containers)

