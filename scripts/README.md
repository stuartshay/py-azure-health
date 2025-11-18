# Scripts Directory

This directory contains utility scripts for managing the Azure Functions project.

## Available Scripts

### start-function.sh
Starts the Azure Functions host for local development.

**Usage:**
```bash
./scripts/start-function.sh
```

**What it does:**
- Checks if virtual environment exists
- Activates the Python virtual environment
- Verifies Azure Functions Core Tools is installed
- Starts the function host from the `/src` directory
- The function will be available at `http://localhost:7071/api/hello`

**Prerequisites:**
- Virtual environment must be set up (run `./install.sh` first)
- Azure Functions Core Tools must be installed

---

### test-function.sh
Tests the HTTP trigger function by sending requests to it.

**Usage:**
```bash
# Test without parameters
./scripts/test-function.sh

# Test with a name parameter
./scripts/test-function.sh --name "John"

# Test with custom URL
./scripts/test-function.sh --url "http://localhost:7071/api/hello"

# Show help
./scripts/test-function.sh --help
```

**What it does:**
- Sends HTTP requests to the function endpoint
- Supports optional name parameter for personalized responses
- Displays the function's response

**Prerequisites:**
- Function must be running (use `start-function.sh` first)
- `curl` must be installed

---

### stop-function.sh
Stops all running Azure Functions host processes.

**Usage:**
```bash
./scripts/stop-function.sh
```

**What it does:**
- Finds all running `func start` processes
- Gracefully stops them (SIGTERM)
- Force kills if processes don't stop (SIGKILL)

---

## Typical Workflow

1. **First time setup:**
   ```bash
   ./install.sh
   ```

2. **Start the function:**
   ```bash
   ./scripts/start-function.sh
   ```

3. **In another terminal, test the function:**
   ```bash
   ./scripts/test-function.sh --name "YourName"
   ```

4. **Stop the function when done:**
   ```bash
   ./scripts/stop-function.sh
   ```

## Notes

- All scripts are designed to be run from the project root directory
- The scripts will automatically handle path resolution
- Make sure scripts have execute permissions (they should by default)
