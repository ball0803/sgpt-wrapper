#!/bin/bash
# test_helper.bash - Common test utilities for sgpt-wrapper tests
# Provides assertion functions, mock utilities, and colored output

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
CURRENT_TEST_NAME=""

# Track test suite
TEST_SUITE_NAME="${TEST_SUITE_NAME:-default}"

# ============================================================================
# Assertion Functions
# ============================================================================

# Assert two values are equal
# Usage: assert_equal "expected" "actual" "test name"
assert_equal() {
    local expected="$1"
    local actual="$2"
    local test_name="${3:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

# Assert command succeeds (exit code 0)
# Usage: assert_success "command" "test name"
assert_success() {
    local cmd="$1"
    local test_name="${2:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    eval "$cmd" > /dev/null 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Command failed with exit code: $exit_code"
        return 1
    fi
}

# Assert command fails (non-zero exit code)
# Usage: assert_failure "command" "test name"
assert_failure() {
    local cmd="$1"
    local test_name="${2:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    eval "$cmd" > /dev/null 2>&1
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Command succeeded but expected failure"
        return 1
    fi
}

# Assert output contains string
# Usage: assert_output_contains "command" "substring" "test name"
assert_output_contains() {
    local cmd="$1"
    local expected_substring="$2"
    local test_name="${3:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    local output
    output=$(eval "$cmd" 2>&1)
    
    if echo "$output" | grep -q "$expected_substring"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Expected output to contain: '$expected_substring'"
        echo "  Actual output: $output"
        return 1
    fi
}

# Assert file exists
# Usage: assert_file_exists "/path/to/file" "test name"
assert_file_exists() {
    local file="$1"
    local test_name="${2:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    if [ -f "$file" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  File does not exist: $file"
        return 1
    fi
}

# Assert directory exists
# Usage: assert_dir_exists "/path/to/dir" "test name"
assert_dir_exists() {
    local dir="$1"
    local test_name="${2:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    if [ -d "$dir" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Directory does not exist: $dir"
        return 1
    fi
}

# ============================================================================
# Mock Functions
# ============================================================================

# Create a mock function that returns specified value
# Usage: mock_function "function_name" "return_value"
mock_function() {
    local func_name="$1"
    local return_val="$2"
    
    eval "$func_name() { echo '$return_val'; return 0; }"
}

# Create a mock function that fails
# Usage: mock_failure "function_name" "exit_code"
mock_failure() {
    local func_name="$1"
    local exit_code="${2:-1}"
    
    eval "$func_name() { return $exit_code; }"
}

# Create a mock command that outputs specified text
# Usage: mock_command "command_name" "output"
mock_command() {
    local cmd_name="$1"
    local output="$2"
    
    eval "$cmd_name() { echo '$output'; }"
}

# Create a mock that records calls
# Usage: mock_record_calls "function_name" "call_log_var"
mock_record_calls() {
    local func_name="$1"
    local call_log_var="$2"
    
    eval "$func_name() { 
        eval \"$call_log_var=\\\"\\${$call_log_var}\$* \\\"\"
    }"
}

# Mock stdin for testing
# Usage: mock_stdin "file_with_input"
mock_stdin() {
    local input_file="$1"
    exec 0<"$input_file"
}

# ============================================================================
# Test Lifecycle Functions
# ============================================================================

# Setup function - called before each test
setup() {
    # Can be overridden in test files
    :
}

# Teardown function - called after each test
teardown() {
    # Can be overridden in test files
    :
}

# Run a single test
# Usage: run_test "test_name" "test_function"
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    setup
    $test_func
    local result=$?
    teardown
    
    return $result
}

# ============================================================================
# Test Suite Functions
# ============================================================================

# Print test suite header
print_suite_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Test Suite: $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Print test summary
print_summary() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "Test Summary: $TEST_SUITE_NAME"
    echo -e "Total:  $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        return 1
    fi
    return 0
}

# Reset test counters
reset_counters() {
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    CURRENT_TEST_NAME=""
}

# Skip a test
# Usage: skip "reason"
skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# ============================================================================
# Export functions for use in subshells
# ============================================================================

export -f assert_equal
export -f assert_success
export -f assert_failure
export -f assert_output_contains
export -f assert_file_exists
export -f assert_dir_exists
export -f mock_function
export -f mock_failure
export -f mock_command
export -f mock_record_calls
export -f setup
export -f teardown
export -f run_test
export -f print_suite_header
export -f print_summary
export -f reset_counters
export -f skip
