#!/bin/bash

# Azure Functions Test Script
# Tests the HTTP trigger function locally

set -e

echo "=========================================="
echo "Testing Azure Functions"
echo "=========================================="

# Default values
FUNCTION_URL="http://localhost:7071/api/hello"
NAME=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            NAME="$2"
            shift 2
            ;;
        --url)
            FUNCTION_URL="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --name NAME    Name to pass to the function (optional)"
            echo "  --url URL      Function URL (default: http://localhost:7071/api/hello)"
            echo "  --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed."
    exit 1
fi

echo ""
echo "Testing function at: $FUNCTION_URL"

if [ -n "$NAME" ]; then
    echo "With name parameter: $NAME"
    echo ""
    curl -s "${FUNCTION_URL}?name=${NAME}"
else
    echo "Without parameters"
    echo ""
    curl -s "$FUNCTION_URL"
fi

echo ""
echo ""
echo "=========================================="
echo "Test completed"
echo "=========================================="
