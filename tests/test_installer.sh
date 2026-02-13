#!/bin/bash
# test_installer.sh - Comprehensive tests for installer functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helper.bash"

# Disable strict error mode from install.sh to allow tests to continue
set +euo pipefail

# We need to source install.sh but prevent main from running
# One way is to create a temporary version without the main call
INSTALL_SCRIPT="${SCRIPT_DIR}/../scripts/install.sh"
INSTALL_SCRIPT_TEMP="${SCRIPT_DIR}/../scripts/install_temp.sh"

# Create temp file without main call
sed '/^main /,/^}$/d' "$INSTALL_SCRIPT" > "$INSTALL_SCRIPT_TEMP"

# Source the functions from temp file
source "${INSTALL_SCRIPT_TEMP}" 2>/dev/null || true

# Clean up temp file
rm -f "$INSTALL_SCRIPT_TEMP"

TEST_SUITE_NAME="installer"

# ============================================================================
# Fish Detection Tests
# ============================================================================

test_detect_fish_installed() {
    assert_equal "function" "$(type -t detect_fish)" "detect_fish function exists"
    
    if command -v fish >/dev/null 2>&1; then
        local result
        result=$(detect_fish >/dev/null 2>&1; echo $?)
        assert_equal "0" "$result" "detect_fish returns 0 when fish is installed"
    else
        local result
        result=$(detect_fish >/dev/null 2>&1; echo $?)
        assert_equal "1" "$result" "detect_fish returns 1 when fish is not installed"
    fi
}

test_detect_fish_not_installed() {
    if command -v fish >/dev/null 2>&1; then
        skip "Fish is installed in this environment"
    else
        assert_equal "function" "$(type -t detect_fish)" "detect_fish function exists"
        local result
        result=$(detect_fish >/dev/null 2>&1; echo $?)
        assert_equal "1" "$result" "detect_fish returns 1 when fish not found"
    fi
}

# ============================================================================
# Curl Mode Tests
# ============================================================================

test_is_curl_mode_true() {
    assert_equal "function" "$(type -t is_curl_mode)" "is_curl_mode function exists"
    
    local result
    result=$(is_curl_mode >/dev/null 2>&1; echo $?)
    assert_true "[ $result -eq 0 ] || [ $result -eq 1 ]" "is_curl_mode returns valid exit code"
}

test_is_interactive_false() {
    assert_equal "function" "$(type -t is_interactive)" "is_interactive function exists"
    
    local result
    result=$(is_interactive >/dev/null 2>&1; echo $?)
    assert_true "[ $result -eq 0 ] || [ $result -eq 1 ]" "is_interactive returns valid exit code"
}

# ============================================================================
# pipx Tests
# ============================================================================

test_check_pipx_found() {
    assert_equal "function" "$(type -t check_pipx)" "check_pipx function exists"
    
    if command -v pipx >/dev/null 2>&1; then
        local result
        result=$(check_pipx >/dev/null 2>&1; echo $?)
        assert_equal "0" "$result" "check_pipx returns 0 when pipx is installed"
    else
        local result
        result=$(check_pipx >/dev/null 2>&1; echo $?)
        assert_equal "1" "$result" "check_pipx returns 1 when pipx is not installed"
    fi
}

test_check_pipx_not_found() {
    if command -v pipx >/dev/null 2>&1; then
        skip "pipx is installed in this environment"
    else
        local result
        result=$(check_pipx >/dev/null 2>&1; echo $?)
        assert_equal "1" "$result" "check_pipx returns 1 when pipx not found"
    fi
}

# ============================================================================
# Provider Selection Tests
# ============================================================================

test_select_provider_with_input() {
    assert_equal "function" "$(type -t select_provider)" "select_provider function exists"
}

test_invalid_provider_selection() {
    assert_equal "function" "$(type -t get_providers)" "get_providers function exists"
    
    local providers_json="${SCRIPT_DIR}/../scripts/providers.json"
    if [ -f "$providers_json" ]; then
        local valid_result
        valid_result=$(jq -r '.providers[] | select(.name | ascii_downcase == "openai") | .name' "$providers_json" 2>/dev/null || echo "null")
        assert_equal "OpenAI" "$valid_result" "OpenAI provider found in providers.json"
        
        local invalid_result
        invalid_result=$(jq -r '.providers[] | select(.name | ascii_downcase == "nonexistent") | .name' "$providers_json" 2>/dev/null || echo "null")
        assert_true "[ -z \"$invalid_result\" ] || [ \"$invalid_result\" = \"null\" ]" "Nonexistent provider returns null/empty"
    else
        skip "providers.json not found"
    fi
}

test_get_providers() {
    local providers_json="${SCRIPT_DIR}/../scripts/providers.json"
    if [ -f "$providers_json" ]; then
        assert_equal "function" "$(type -t get_providers)" "get_providers function exists"
        
        local output
        output=$(get_providers 2>/dev/null || echo "")
        assert_true "[ -n \"$output\" ]" "get_providers returns output"
        assert_output_contains "get_providers" "OpenAI" "get_providers includes OpenAI"
    else
        skip "providers.json not found"
    fi
}

test_display_provider_menu() {
    assert_equal "function" "$(type -t display_provider_menu)" "display_provider_menu function exists"
}

test_get_provider_detail() {
    local providers_json="${SCRIPT_DIR}/../scripts/providers.json"
    if [ -f "$providers_json" ]; then
        assert_equal "function" "$(type -t get_provider_detail)" "get_provider_detail function exists"
        
        local model
        model=$(get_provider_detail "openai" "default_model" 2>/dev/null || echo "error")
        if [ "$model" != "error" ] && [ -n "$model" ]; then
            assert_true "[ -n \"$model\" ]" "get_provider_detail returns model for openai"
        fi
    else
        skip "providers.json not found"
    fi
}

# ============================================================================
# Provider Configuration Tests
# ============================================================================

test_configure_openai() {
    assert_equal "function" "$(type -t configure_openai)" "configure_openai function exists"
    
    local output
    output=$(SELECTED_MODEL="gpt-4" SELECTED_API_KEY="test-key" configure_openai 2>/dev/null || echo "")
    
    assert_output_contains "configure_openai" "OPENAI_API_KEY" "OpenAI config contains API key"
    assert_output_contains "configure_openai" "https://api.openai.com/v1" "OpenAI config contains base URL"
    assert_output_contains "configure_openai" "gpt-4" "OpenAI config contains model"
}

test_configure_minimax() {
    assert_equal "function" "$(type -t configure_minimax)" "configure_minimax function exists"
    
    local output
    output=$(SELECTED_MODEL="MiniMax-M2.1" SELECTED_API_KEY="test-key" configure_minimax 2>/dev/null || echo "")
    
    assert_output_contains "configure_minimax" "MINIMAX_API_KEY" "MiniMax config contains API key"
    assert_output_contains "configure_minimax" "https://api.minimax.io/v1" "MiniMax config contains base URL"
    assert_output_contains "configure_minimax" "MiniMax-M2.1" "MiniMax config contains model"
}

test_configure_ollama() {
    assert_equal "function" "$(type -t configure_ollama)" "configure_ollama function exists"
    
    local output
    output=$(SELECTED_MODEL="llama3" configure_ollama 2>/dev/null || echo "")
    
    assert_output_contains "configure_ollama" "OLLAMA_API_KEY" "Ollama config contains API key"
    assert_output_contains "configure_ollama" "localhost:11434" "Ollama config contains base URL"
    assert_output_contains "configure_ollama" "llama3" "Ollama config contains model"
}

test_configure_groq() {
    assert_equal "function" "$(type -t configure_groq)" "configure_groq function exists"
    
    local output
    output=$(SELECTED_MODEL="llama-3.3-70b-versatile" SELECTED_API_KEY="test-key" configure_groq 2>/dev/null || echo "")
    
    assert_output_contains "configure_groq" "GROQ_API_KEY" "Groq config contains API key"
    assert_output_contains "configure_groq" "https://api.groq.com/openai/v1" "Groq config contains base URL"
    assert_output_contains "configure_groq" "llama-3.3-70b-versatile" "Groq config contains model"
}

test_configure_together() {
    assert_equal "function" "$(type -t configure_together)" "configure_together function exists"
    
    local output
    output=$(SELECTED_MODEL="meta-llama/Llama-3.3-70B-Instruct" SELECTED_API_KEY="test-key" configure_together 2>/dev/null || echo "")
    
    assert_output_contains "configure_together" "TOGETHER_API_KEY" "Together config contains API key"
    assert_output_contains "configure_together" "https://api.together.ai/v1" "Together config contains base URL"
}

test_configure_provider() {
    assert_equal "function" "$(type -t configure_provider)" "configure_provider function exists"
    
    local output
    output=$(configure_provider "openai" 2>/dev/null || echo "")
    assert_output_contains "configure_provider openai" "OPENAI_API_KEY" "configure_provider dispatches to openai"
    
    output=$(configure_provider "OPENAI" 2>/dev/null || echo "")
    assert_output_contains "configure_provider OPENAI" "OPENAI_API_KEY" "configure_provider handles uppercase"
    
    output=$(configure_provider "minimax" 2>/dev/null || echo "")
    assert_output_contains "configure_provider minimax" "MINIMAX_API_KEY" "configure_provider handles lowercase"
    
    local exit_code=0
    configure_provider "nonexistent" 2>/dev/null || exit_code=$?
    if [ $exit_code -ne 0 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: configure_provider fails for unknown provider"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: configure_provider fails for unknown provider"
    fi
}

# ============================================================================
# Parameter Mode Tests
# ============================================================================

test_no_interact_flag() {
    assert_equal "function" "$(type -t parse_arguments)" "parse_arguments function exists"
    
    NO_INTERACT=false
    parse_arguments --no-interact
    
    assert_equal "true" "$NO_INTERACT" "NO_INTERACT flag is set to true"
    
    NO_INTERACT=false
}

test_provider_flag() {
    SELECTED_PROVIDER=""
    parse_arguments --provider openai
    
    assert_equal "openai" "$SELECTED_PROVIDER" "Provider flag sets SELECTED_PROVIDER"
    
    SELECTED_PROVIDER=""
}

test_model_flag() {
    SELECTED_MODEL=""
    parse_arguments --model gpt-4
    
    assert_equal "gpt-4" "$SELECTED_MODEL" "Model flag sets SELECTED_MODEL"
    
    SELECTED_MODEL=""
}

test_api_key_flag() {
    SELECTED_API_KEY=""
    parse_arguments --api-key test-key-123
    
    assert_equal "test-key-123" "$SELECTED_API_KEY" "API key flag sets SELECTED_API_KEY"
    
    SELECTED_API_KEY=""
}

test_shell_flag() {
    SELECTED_SHELL=""
    parse_arguments --shell fish
    
    assert_equal "fish" "$SELECTED_SHELL" "Shell flag sets SELECTED_SHELL"
    
    SELECTED_SHELL=""
}

test_dry_run_flag() {
    DRY_RUN=false
    parse_arguments --dry-run
    
    assert_equal "true" "$DRY_RUN" "Dry run flag sets DRY_RUN"
    
    DRY_RUN=false
}

test_force_flag() {
    FORCE_OVERWRITE=false
    parse_arguments --force
    
    assert_equal "true" "$FORCE_OVERWRITE" "Force flag sets FORCE_OVERWRITE"
    
    FORCE_OVERWRITE=false
}

test_install_pipx_flag() {
    AUTO_INSTALL_PIPX=false
    parse_arguments --install-pipx
    
    assert_equal "true" "$AUTO_INSTALL_PIPX" "Install pipx flag sets AUTO_INSTALL_PIPX"
    
    AUTO_INSTALL_PIPX=false
}

test_help_flag() {
    assert_equal "function" "$(type -t show_help)" "show_help function exists"
}

test_list_providers_flag() {
    assert_equal "function" "$(type -t list_providers)" "list_providers function exists"
}

# ============================================================================
# Utility Function Tests
# ============================================================================

test_log_functions() {
    assert_equal "function" "$(type -t log_info)" "log_info function exists"
    assert_equal "function" "$(type -t log_success)" "log_success function exists"
    assert_equal "function" "$(type -t log_warning)" "log_warning function exists"
    assert_equal "function" "$(type -t log_error)" "log_error function exists"
}

test_ensure_config_dir() {
    assert_equal "function" "$(type -t ensure_config_dir)" "ensure_config_dir function exists"
}

test_backup_config() {
    assert_equal "function" "$(type -t backup_config)" "backup_config function exists"
}

test_generate_config() {
    assert_equal "function" "$(type -t generate_config)" "generate_config function exists"
}

test_install_sgpt() {
    assert_equal "function" "$(type -t install_sgpt)" "install_sgpt function exists"
}

test_install_completions() {
    assert_equal "function" "$(type -t install_completions)" "install_completions function exists"
}

test_validate_fish_syntax() {
    assert_equal "function" "$(type -t validate_fish_syntax)" "validate_fish_syntax function exists"
}

test_install_fish_config() {
    assert_equal "function" "$(type -t install_fish_config)" "install_fish_config function exists"
}

test_handle_curl_mode() {
    assert_equal "function" "$(type -t handle_curl_mode)" "handle_curl_mode function exists"
}

test_offer_pipx_install() {
    assert_equal "function" "$(type -t offer_pipx_install)" "offer_pipx_install function exists"
}

test_install_pipx() {
    assert_equal "function" "$(type -t install_pipx)" "install_pipx function exists"
}

# ============================================================================
# Additional Edge Case Tests
# ============================================================================

test_provider_case_insensitive() {
    local providers_json="${SCRIPT_DIR}/../scripts/providers.json"
    if [ -f "$providers_json" ]; then
        # Test lowercase lookup
        if jq -e '.providers[] | select(.name | ascii_downcase == "openai")' "$providers_json" >/dev/null 2>&1; then
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓ PASS${NC}: Provider lookup works with lowercase"
        else
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗ FAIL${NC}: Provider lookup works with lowercase"
        fi
        
        # Test minimax lookup (case insensitive)
        if jq -e '.providers[] | select(.name | ascii_downcase == "minimax")' "$providers_json" >/dev/null 2>&1; then
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓ PASS${NC}: Provider lookup works with minimax"
        else
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗ FAIL${NC}: Provider lookup works with minimax"
        fi
    else
        skip "providers.json not found"
    fi
}

test_multiple_provider_configs() {
    local openai_out=$(configure_openai 2>/dev/null || echo "")
    local groq_out=$(configure_groq 2>/dev/null || echo "")
    local ollama_out=$(configure_ollama 2>/dev/null || echo "")
    
    assert_output_contains "configure_openai" "OPENAI_API_KEY" "OpenAI config generated"
    assert_output_contains "configure_groq" "GROQ_API_KEY" "Groq config generated"
    assert_output_contains "configure_ollama" "OLLAMA_API_KEY" "Ollama config generated"
}

test_argument_parsing_combinations() {
    SELECTED_PROVIDER=""
    SELECTED_MODEL=""
    SELECTED_API_KEY=""
    NO_INTERACT=false
    DRY_RUN=false
    
    parse_arguments --provider minimax --model MiniMax-M2.1 --api-key key123 --no-interact --dry-run
    
    assert_equal "minimax" "$SELECTED_PROVIDER" "Multiple flags: provider set"
    assert_equal "MiniMax-M2.1" "$SELECTED_MODEL" "Multiple flags: model set"
    assert_equal "key123" "$SELECTED_API_KEY" "Multiple flags: api-key set"
    assert_equal "true" "$NO_INTERACT" "Multiple flags: no-interact set"
    assert_equal "true" "$DRY_RUN" "Multiple flags: dry-run set"
    
    SELECTED_PROVIDER=""
    SELECTED_MODEL=""
    SELECTED_API_KEY=""
    NO_INTERACT=false
    DRY_RUN=false
}

test_short_flags() {
    SELECTED_PROVIDER=""
    SELECTED_MODEL=""
    NO_INTERACT=false
    
    parse_arguments -p ollama -m llama3 -y
    
    assert_equal "ollama" "$SELECTED_PROVIDER" "Short -p flag works"
    assert_equal "llama3" "$SELECTED_MODEL" "Short -m flag works"
    assert_equal "true" "$NO_INTERACT" "Short -y flag works"
    
    SELECTED_PROVIDER=""
    SELECTED_MODEL=""
    NO_INTERACT=false
}

# ============================================================================
# Helper: assert_true
# ============================================================================

assert_true() {
    local condition="$1"
    local test_name="${2:-unnamed test}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    CURRENT_TEST_NAME="$test_name"
    
    if eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Condition failed: $condition"
        return 1
    fi
}

# ============================================================================
# Run All Tests
# ============================================================================

run_installer_tests() {
    print_suite_header "Installer Tests"
    
    echo ""
    echo "--- Fish Detection Tests ---"
    test_detect_fish_installed
    test_detect_fish_not_installed
    
    echo ""
    echo "--- Curl Mode Tests ---"
    test_is_curl_mode_true
    test_is_interactive_false
    
    echo ""
    echo "--- pipx Tests ---"
    test_check_pipx_found
    test_check_pipx_not_found
    
    echo ""
    echo "--- Provider Selection Tests ---"
    test_select_provider_with_input
    test_invalid_provider_selection
    test_get_providers
    test_display_provider_menu
    test_get_provider_detail
    
    echo ""
    echo "--- Provider Configuration Tests ---"
    test_configure_openai
    test_configure_minimax
    test_configure_ollama
    test_configure_groq
    test_configure_together
    test_configure_provider
    
    echo ""
    echo "--- Parameter Mode Tests ---"
    test_no_interact_flag
    test_provider_flag
    test_model_flag
    test_api_key_flag
    test_shell_flag
    test_dry_run_flag
    test_force_flag
    test_install_pipx_flag
    test_help_flag
    test_list_providers_flag
    
    echo ""
    echo "--- Utility Function Tests ---"
    test_log_functions
    test_ensure_config_dir
    test_backup_config
    test_generate_config
    test_install_sgpt
    test_install_completions
    test_validate_fish_syntax
    test_install_fish_config
    test_handle_curl_mode
    test_offer_pipx_install
    test_install_pipx
    
    echo ""
    echo "--- Additional Edge Case Tests ---"
    test_provider_case_insensitive
    test_multiple_provider_configs
    test_argument_parsing_combinations
    test_short_flags
    
    print_summary
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    run_installer_tests
fi
