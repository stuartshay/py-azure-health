# Use Python 3.14 slim image as base
# Azure Functions for Python supports 3.9, 3.10, 3.11, 3.14
ARG VARIANT="3.14-slim-bookworm"
FROM python:${VARIANT}

# Note: Most dependencies are installed via Dev Container Features:
# - common-utils: git, curl, wget, ca-certificates, non-root user (vscode)
# - python: Python tools and pip
# - node: Node.js (for Azure Functions Core Tools)
# - azure-cli: Azure CLI
# - dotnet: .NET SDK (for Bicep and other tools)
# - azure-functions-core-tools: Azure Functions Core Tools v4
# - pre-commit: Pre-commit framework
# - docker-in-docker: Docker daemon
# - github-cli: gh CLI tool
# - azd: Azure Developer CLI

# Set bash as the default shell
ENV SHELL=/bin/bash
