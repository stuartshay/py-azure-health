# Dev Container Features

This document describes the Dev Container Features used in this project and their benefits.

## What are Dev Container Features?

Dev Container Features are self-contained units of installation code and configuration that add specific tools or runtimes to a development container. They are reusable, maintained by the community, and follow best practices.

## Features Used

### 1. Common Utilities (`ghcr.io/devcontainers/features/common-utils:2`)
**Provides:**
- Git, curl, wget, ca-certificates
- Non-root user (vscode) creation
- Sudo configuration

**Configuration:**
```json
{
  "installZsh": false,
  "installOhMyZsh": false,
  "upgradePackages": true,
  "username": "vscode",
  "uid": "1000",
  "gid": "1000"
}
```

**Benefits:**
- Automatic user creation with proper permissions
- Pre-configured sudo access
- Common utilities installed and maintained

### 2. Python (`ghcr.io/devcontainers/features/python:1`)
**Purpose:** Installs Python runtime and development tools.

- Python 3.14 runtime
- pip (Python package manager)

**Configuration:**
```json
{
  "version": "3.14",
  "installTools": true
}
```

**Benefits:**
- Specific Python version control
- pip and venv automatically configured
- Python tools (pipx, etc.) available

### 3. Node.js (`ghcr.io/devcontainers/features/node:1`)
**Provides:**
- Node.js 20 LTS
- npm and node-gyp dependencies

**Configuration:**
```json
{
  "version": "20",
  "nodeGypDependencies": true,
  "installYarnUsingApt": false
}
```

**Benefits:**
- LTS version pinning
- npm pre-configured
- Required by Azure Functions Core Tools

### 4. Azure CLI (`ghcr.io/devcontainers/features/azure-cli:1`)
**Provides:**
- Azure CLI
- Bicep CLI (optional)

**Configuration:**
```json
{
  "version": "latest",
  "installBicep": true
}
```

**Benefits:**
- Always up-to-date Azure CLI
- Bicep support for IaC
- Automatic updates

### 5. .NET SDK (`ghcr.io/devcontainers/features/dotnet:2`)
**Provides:**
- .NET 8 SDK
- Required by Azure Functions Core Tools

**Configuration:**
```json
{
  "version": "8.0",
  "installUsingApt": true
}
```

**Benefits:**
- Specific .NET version
- Required for Functions tooling
- Fast installation via apt

### 6. Pre-commit (`ghcr.io/prulloac/devcontainer-features/pre-commit:1`)
**Provides:**
- Pre-commit framework

**Configuration:**
```json
{
  "version": "latest"
}
```

**Benefits:**
- Pre-commit framework installed
- Proper PATH configuration
- Automatic updates

### 7. Docker-in-Docker (`ghcr.io/devcontainers/features/docker-in-docker:2`)
**Provides:**
- Docker daemon inside the container
- Docker CLI and Compose v2

**Configuration:**
```json
{
  "version": "latest",
  "moby": true,
  "dockerDashComposeVersion": "v2"
}
```

**Benefits:**
- Build and run containers inside the devcontainer
- Docker Compose support
- Useful for testing containerized workloads

### 8. GitHub CLI (`ghcr.io/devcontainers/features/github-cli:1`)
**Provides:**
- gh command for GitHub operations

**Configuration:**
```json
{
  "version": "latest",
  "installDirectlyFromGitHubRelease": true
}
```

**Benefits:**
- Interact with GitHub from terminal
- Create issues, PRs, etc.
- Direct from official releases

### 9. Azure Developer CLI (`ghcr.io/azure/azure-dev/azd:0`)
**Provides:**
- azd command for Azure development

**Configuration:**
```json
{
  "version": "latest"
}
```

**Benefits:**
- Simplified Azure deployments
- Project templates
- Infrastructure management

### 10. Azure Functions Core Tools (`ghcr.io/jlaundry/devcontainer-features/azure-functions-core-tools:1`)
**Provides:**
- Azure Functions Core Tools v4
- func CLI for local development

**Configuration:**
```json
{
  "version": "4"
}
```

**Benefits:**
- Faster installation (pre-compiled binaries)
- No npm network dependency during build
- More reliable than npm global install
- Community-maintained feature

## What Remains in Custom Scripts

### Dockerfile
- Base Python image
- Shell configuration
- Comments documenting feature usage

### post-create.sh
- Python package installation (requirements.txt)
- Python development tools (black, flake8, pytest, mypy)
- Pre-commit hooks installation
- local.settings.json creation
- Azurite workspace directory creation
- Azure-specific tools (azure-cost-cli)

## Benefits of Using Features

1. **Maintenance**: Features are maintained by the community
2. **Best Practices**: Features follow container best practices
3. **Consistency**: Same features work across different base images
4. **Updates**: Easy to update by changing version numbers
5. **Documentation**: Well-documented at containers.dev
6. **Compatibility**: Tested across different scenarios
7. **Smaller Dockerfiles**: Less custom code to maintain

## Dockerfile Size Comparison

**Without Features:** ~100+ lines with manual installations
**With Features:** ~15 lines, most work delegated to features

## Testing

After building the container, verify all tools are available:

```bash
# Verify installation
```bash
python --version         # Python 3.14.x
pip --version
node --version           # Node.js 20.x
```

## Migration Path for Other Projects

To adopt this pattern in other projects:

1. Identify manual installations in Dockerfile
2. Search for matching features at https://containers.dev/features
3. Add features to `devcontainer.json`
4. Remove redundant Dockerfile RUN commands
5. Keep project-specific installations in post-create scripts
6. Test thoroughly

## Available Feature Catalogs

- **Official Features**: https://github.com/devcontainers/features
- **Community Features**: https://containers.dev/collections
- **Create Custom Features**: https://containers.dev/guide/creating-features

## References

- [Dev Container Features Specification](https://containers.dev/implementors/features/)
- [Official Feature Repository](https://github.com/devcontainers/features)
- [Community Feature Directory](https://containers.dev/collections)
