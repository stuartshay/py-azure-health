#!/bin/bash

# Azure Functions Stop Script
# Stops any running Azure Functions host processes

set -e

echo "=========================================="
echo "Stopping Azure Functions"
echo "=========================================="

# Find and kill func processes
FUNC_PIDS=$(pgrep -f "func start" || true)

if [ -z "$FUNC_PIDS" ]; then
    echo "No running Azure Functions processes found."
else
    echo "Found Azure Functions processes: $FUNC_PIDS"
    echo "Stopping processes..."
    kill $FUNC_PIDS
    sleep 2

    # Check if processes are still running and force kill if needed
    FUNC_PIDS=$(pgrep -f "func start" || true)
    if [ -n "$FUNC_PIDS" ]; then
        echo "Force stopping processes..."
        kill -9 $FUNC_PIDS
    fi

    echo "Azure Functions stopped successfully."
fi

echo "=========================================="
