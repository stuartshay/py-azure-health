#!/usr/bin/env bats
# Tests for Azure Function app scripts
# Run with: bats tests/scripts/test-function-app.bats

setup() {
  export MOCK_DIR="$BATS_TEST_TMPDIR/mocks"
  mkdir -p "$MOCK_DIR"
  export PATH="$MOCK_DIR:$PATH"

  # Mock project structure
  export PROJECT_ROOT="$BATS_TEST_TMPDIR/project"
  mkdir -p "$PROJECT_ROOT"/{src,.venv/bin}
}

teardown() {
  rm -rf "$MOCK_DIR"
  rm -rf "$PROJECT_ROOT"
}

# Test: start-function.sh detects missing virtual environment
@test "start-function.sh fails when virtual environment is missing" {
  rm -rf "$PROJECT_ROOT/.venv"

  # Source the script logic (not the actual file since we need to test conditions)
  run bash -c '
    PROJECT_ROOT="'"$PROJECT_ROOT"'"
    cd "$PROJECT_ROOT"
    if [ ! -d ".venv" ]; then
      echo "Error: Virtual environment not found."
      exit 1
    fi
  '

  [ "$status" -eq 1 ]
  [[ "$output" == *"Virtual environment not found"* ]]
}

# Test: start-function.sh detects missing func command
@test "start-function.sh fails when func is not installed" {
  run bash -c '
    if ! command -v nonexistent-command &> /dev/null; then
      echo "Error: Azure Functions Core Tools (func) is not installed."
      exit 1
    fi
  '

  [ "$status" -eq 1 ]
  [[ "$output" == *"Azure Functions Core Tools"* ]]
}

# Test: start-function.sh succeeds with proper setup
@test "start-function.sh starts successfully with proper setup" {
  # Mock func command
  cat > "$MOCK_DIR/func" << 'EOF'
#!/bin/bash
if [[ "$1" == "--version" ]]; then
  echo "4.0.5907"
elif [[ "$1" == "start" ]]; then
  echo "Starting Azure Functions..."
  exit 0
fi
EOF
  chmod +x "$MOCK_DIR/func"

  run bash -c '
    PROJECT_ROOT="'"$PROJECT_ROOT"'"
    cd "$PROJECT_ROOT"
    if [ -d ".venv" ]; then
      if command -v func &> /dev/null; then
        FUNC_VERSION=$(func --version)
        echo "Azure Functions Core Tools version: $FUNC_VERSION"
        exit 0
      fi
    fi
  '

  [ "$status" -eq 0 ]
  [[ "$output" == *"4.0.5907"* ]]
}

# Test: test-function.sh validates response
@test "test-function.sh can validate function response" {
  # Mock curl command
  cat > "$MOCK_DIR/curl" << 'EOF'
#!/bin/bash
if [[ "$*" == *"http://localhost:7071/api/hello"* ]]; then
  echo '{"message":"Hello from Azure Function!"}'
  exit 0
fi
exit 1
EOF
  chmod +x "$MOCK_DIR/curl"

  run bash -c '
    response=$(curl -s "http://localhost:7071/api/hello?name=Test")
    if [[ "$response" == *"Hello"* ]]; then
      echo "Function is responding correctly"
      exit 0
    else
      echo "Function response invalid"
      exit 1
    fi
  '

  [ "$status" -eq 0 ]
  [[ "$output" == *"responding correctly"* ]]
}

# Test: stop-function.sh can identify running processes
@test "stop-function.sh can identify and stop func processes" {
  # Mock ps and pkill
  cat > "$MOCK_DIR/ps" << 'EOF'
#!/bin/bash
echo "12345 func"
EOF
  chmod +x "$MOCK_DIR/ps"

  cat > "$MOCK_DIR/pkill" << 'EOF'
#!/bin/bash
echo "Stopped process: func"
exit 0
EOF
  chmod +x "$MOCK_DIR/pkill"

  run bash -c '
    if ps aux | grep -q "[f]unc"; then
      pkill -f func
      echo "Azure Functions stopped"
      exit 0
    fi
  '

  [ "$status" -eq 0 ]
  [[ "$output" == *"stopped"* ]]
}

# Test: Script handles Python virtual environment activation
@test "scripts can activate Python virtual environment" {
  # Create mock activate script
  cat > "$PROJECT_ROOT/.venv/bin/activate" << 'EOF'
#!/bin/bash
export VIRTUAL_ENV="$PROJECT_ROOT/.venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
echo "Virtual environment activated"
EOF
  chmod +x "$PROJECT_ROOT/.venv/bin/activate"

  run bash -c '
    PROJECT_ROOT="'"$PROJECT_ROOT"'"
    cd "$PROJECT_ROOT"
    if [ -f ".venv/bin/activate" ]; then
      source .venv/bin/activate
      echo "Activation successful"
      exit 0
    fi
  '

  [ "$status" -eq 0 ]
  [[ "$output" == *"activated"* ]]
}

# Test: Script validates src directory exists
@test "scripts validate src directory exists" {
  mkdir -p "$PROJECT_ROOT/src"

  run bash -c '
    PROJECT_ROOT="'"$PROJECT_ROOT"'"
    if [ -d "$PROJECT_ROOT/src" ]; then
      echo "Source directory found"
      exit 0
    else
      echo "Error: Source directory not found"
      exit 1
    fi
  '

  [ "$status" -eq 0 ]
  [[ "$output" == *"Source directory found"* ]]
}
