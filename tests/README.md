# Tests

This directory contains automated tests for the py-azure-health project.

## Directory Structure

```
tests/
├── workflows/           # Tests for CI/CD workflow scripts
│   └── policy-query.bats
├── scripts/             # Tests for utility scripts
│   └── test-function-app.bats
└── README.md
```

## BATS Testing

This project uses [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for testing shell scripts.

### Running Tests Locally

**Prerequisites:**
- BATS is pre-installed in the devcontainer
- `jq` for JSON processing (pre-installed)
- `shellcheck` for shell script linting (pre-installed)

**Run all tests:**
```bash
bats tests/**/*.bats
```

**Run specific test file:**
```bash
bats tests/workflows/policy-query.bats
bats tests/scripts/test-function-app.bats
```

**Run with verbose output:**
```bash
bats -t tests/workflows/policy-query.bats
```

### Test Coverage

#### Workflow Scripts (`tests/workflows/`)

**policy-query.bats** - Tests for Azure Policy query utilities:
- ✅ Policy assignment queries
- ✅ Policy exemption queries
- ✅ Compliance state retrieval
- ✅ Non-compliant resource detection
- ✅ Markdown formatting functions
- ✅ Complete policy report generation
- ✅ Error handling and edge cases

#### Utility Scripts (`tests/scripts/`)

**test-function-app.bats** - Tests for Azure Function app management:
- ✅ Virtual environment validation
- ✅ Azure Functions Core Tools detection
- ✅ Function startup validation
- ✅ Process management
- ✅ HTTP endpoint testing
- ✅ Error handling

## Writing New Tests

### BATS Test Structure

```bash
#!/usr/bin/env bats

# Load test helpers (optional)
load /tmp/bats-support/load
load /tmp/bats-assert/load

# Setup runs before each test
setup() {
  export MOCK_DIR="$BATS_TEST_TMPDIR/mocks"
  mkdir -p "$MOCK_DIR"
}

# Teardown runs after each test
teardown() {
  rm -rf "$MOCK_DIR"
}

# Test case
@test "descriptive test name" {
  run command_to_test
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected output"* ]]
}
```

### Mocking Commands

Create mock executables in the `MOCK_DIR`:

```bash
cat > "$MOCK_DIR/az" << 'EOF'
#!/bin/bash
echo '{"mock": "response"}'
EOF
chmod +x "$MOCK_DIR/az"
export PATH="$MOCK_DIR:$PATH"
```

### Test Assertions

Common BATS assertions:

```bash
[ "$status" -eq 0 ]              # Exit status is 0
[ "$status" -ne 0 ]              # Exit status is not 0
[ "$output" = "exact match" ]    # Exact output match
[[ "$output" == *"substring"* ]] # Output contains substring
[ -f "/path/to/file" ]           # File exists
[ -d "/path/to/dir" ]            # Directory exists
```

## CI/CD Integration

Tests run automatically on:
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`
- Changes to `scripts/**/*.sh` or `tests/**/*.bats`

See `.github/workflows/bats-tests.yml` for CI configuration.

## Best Practices

1. **Test Independence**: Each test should be self-contained
2. **Mock External Dependencies**: Use mocks for `az`, `curl`, etc.
3. **Descriptive Names**: Use clear, descriptive test names
4. **Setup/Teardown**: Clean up resources after each test
5. **Edge Cases**: Test error conditions and edge cases
6. **Fast Tests**: Keep tests fast by mocking slow operations

## Resources

- [BATS Documentation](https://bats-core.readthedocs.io/)
- [BATS Support Library](https://github.com/bats-core/bats-support)
- [BATS Assert Library](https://github.com/bats-core/bats-assert)
- [ShellCheck](https://www.shellcheck.net/)

## Troubleshooting

**Tests fail locally but pass in CI:**
- Ensure you're using the devcontainer environment
- Check that all dependencies are installed

**Mock commands not working:**
- Verify `PATH` includes `$MOCK_DIR`
- Ensure mock scripts have execute permissions (`chmod +x`)

**Tests are slow:**
- Use mocks instead of real Azure CLI commands
- Avoid sleeping or waiting in tests
