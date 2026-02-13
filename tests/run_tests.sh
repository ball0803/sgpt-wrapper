#!/bin/bash
# run_tests.sh - Test runner for sgpt-wrapper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR"

FILTER=""
COVERAGE=false
VERBOSE=false

show_help() {
    cat << EOF
Usage: bash tests/run_tests.sh [OPTIONS]

Run sgpt-wrapper test suite.

OPTIONS:
    --help           Show this help message
    --filter PATTERN Run only tests matching PATTERN
    --coverage       Enable coverage reporting (mock)
    --verbose        Verbose output

EXAMPLES:
    bash tests/run_tests.sh
    bash tests/run_tests.sh --filter installer
    bash tests/run_tests.sh --coverage
    bash tests/run_tests.sh --filter wrapper --verbose

EOF
}

show_coverage() {
    echo ""
    echo "========================================"
    echo "Coverage Report (Mock)"
    echo "========================================"
    echo "Note: Coverage reporting is not yet implemented."
    echo "This is a placeholder for future coverage integration."
    echo ""
    echo "To add real coverage, consider:"
    echo "  - bashcov: https://github.com/infertux/bashcov"
    echo "  - shcov: https://github.com/777ARC/shcov"
    echo ""
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --filter)
                FILTER="$2"
                shift 2
                ;;
            --coverage)
                COVERAGE=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

run_test_file() {
    local test_file="$1"
    local test_name
    test_name=$(basename "$test_file" .sh)
    
    if [ -n "$FILTER" ]; then
        if ! echo "$test_name" | grep -q "$FILTER"; then
            [ "$VERBOSE" = true ] && echo "Skipping: $test_name (does not match filter)"
            return 0
        fi
    fi
    
    [ "$VERBOSE" = true ] && echo "Running: $test_name"
    source "$test_file"
    
    case "$test_file" in
        *test_installer.sh)
            run_installer_tests
            ;;
        *test_wrapper.sh)
            run_wrapper_tests
            ;;
        *)
            if type run_all_tests >/dev/null 2>&1; then
                run_all_tests
            fi
            ;;
    esac
}

main() {
    parse_args "$@"
    
    echo "========================================"
    echo "sgpt-wrapper Test Suite"
    echo "========================================"
    echo ""
    
    local test_files=()
    for f in "$TESTS_DIR"/*.sh; do
        if [ "$(basename "$f")" != "run_tests.sh" ] && [ "$(basename "$f")" != "test_helper.bash" ]; then
            test_files+=("$f")
        fi
    done
    
    if [ ${#test_files[@]} -eq 0 ]; then
        echo "No test files found in $TESTS_DIR"
        exit 1
    fi
    
    echo "Found ${#test_files[@]} test file(s)"
    echo ""
    
    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
    done
    
    if [ "$COVERAGE" = true ]; then
        show_coverage
    fi
    
    echo ""
    echo "========================================"
    echo "All tests completed"
    echo "========================================"
}

main "$@"
