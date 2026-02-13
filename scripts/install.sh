#!/bin/bash
#
# sgpt-wrapper Installer
# A sophisticated, idempotent bash installer for shell-gpt with interactive setup
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
WRAPPER_SOURCE="${BASH_SOURCE[0]%/*}/../bin/sgpt"
INSTALL_DIR="$HOME/bin"
CONFIG_DIR="$HOME/.config/shell_gpt"
CONFIG_FILE="$CONFIG_DIR/.sgptrc"

# Provider endpoints (from requirements)
declare -A PROVIDER_ENDPOINTS=(
    ["openai"]="https://api.openai.com/v1"
    ["minimax"]="https://api.minimax.io/v1"
    ["ollama"]="http://localhost:11434/v1"
    ["together"]="https://api.together.ai/v1"
    ["groq"]="https://api.groq.com/openai/v1"
)

declare -A PROVIDER_MODELS=(
    ["openai"]="gpt-4"
    ["minimax"]="MiniMax-M2.1"
    ["ollama"]="llama2"
    ["together"]="meta-llama/Llama-2-70b-chat-hf"
    ["groq"]="llama2-70b-8192"
)

declare -A PROVIDER_KEY_VARS=(
    ["openai"]="OPENAI_API_KEY"
    ["minimax"]="MINIMAX_API_KEY"
    ["ollama"]="OLLAMA_API_KEY"
    ["together"]="TOGETHER_API_KEY"
    ["groq"]="GROQ_API_KEY"
)

declare -A PROVIDER_URL_VARS=(
    ["openai"]="OPENAI_API_BASE_URL"
    ["minimax"]="MINIMAX_API_BASE_URL"
    ["ollama"]="OLLAMA_API_BASE_URL"
    ["together"]="TOGETHER_API_BASE_URL"
    ["groq"]="GROQ_API_BASE_URL"
)

declare -A PROVIDER_MODEL_VARS=(
    ["openai"]="OPENAI_MODEL"
    ["minimax"]="MINIMAX_MODEL"
    ["ollama"]="OLLAMA_MODEL"
    ["together"]="TOGETHER_MODEL"
    ["groq"]="GROQ_MODEL"
)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Detect current shell
detect_shell() {
    if [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
    elif [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
    elif [[ -n "$FISH_VERSION" ]]; then
        echo "fish"
    else
        echo "unknown"
    fi
}

# Get shell config file path
get_shell_config() {
    local shell="$1"
    case "$shell" in
        bash)
            if [[ -n "$BASHRC" ]]; then
                echo "$BASHRC"
            elif [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.profile"
            fi
            ;;
        zsh)
            if [[ -n "$ZDOTDIR" ]]; then
                echo "$ZDOTDIR/.zshrc"
            elif [[ -f "$HOME/.zshrc" ]]; then
                echo "$HOME/.zshrc"
            else
                echo "$HOME/.zprofile"
            fi
            ;;
        fish)
            if [[ -n "$XDG_CONFIG_HOME" ]]; then
                echo "$XDG_CONFIG_HOME/fish/config.fish"
            else
                echo "$HOME/.config/fish/config.fish"
            fi
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Prompt for yes/no
prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local yn
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " yn
            [[ -z "$yn" ]] && yn="y"
        else
            read -p "$prompt [y/N]: " yn
            [[ -z "$yn" ]] && yn="n"
        fi
        
        case "$yn" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Please answer y or n" ;;
        esac
    done
}

# Prompt for input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " input
        eval "$var_name=\"${input:-$default}\""
    else
        read -p "$prompt: " input
        eval "$var_name=\"$input\""
    fi
}

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

# Check and install pipx
check_pipx() {
    log_header "Checking pipx Installation"
    
    if command -v pipx >/dev/null 2>&1; then
        log_success "pipx is already installed"
        return 0
    fi
    
    log_warning "pipx not found. Attempting to install..."
    
    # Try to install via pip
    if command -v pip >/dev/null 2>&1; then
        log_info "Installing pipx via pip..."
        pip install pipx
        
        if command -v pipx >/dev/null 2>&1; then
            log_success "pipx installed successfully"
            return 0
        fi
    fi
    
    # Try system package manager
    if command -v apt-get >/dev/null 2>&1; then
        log_info "Installing pipx via apt..."
        sudo apt-get update && sudo apt-get install -y pipx
    elif command -v brew >/dev/null 2>&1; then
        log_info "Installing pipx via brew..."
        brew install pipx
    elif command -v dnf >/dev/null 2>&1; then
        log_info "Installing pipx via dnf..."
        sudo dnf install -y pipx
    elif command -v pacman >/dev/null 2>&1; then
        log_info "Installing pipx via pacman..."
        sudo pacman -S --noconfirm python-pipx
    fi
    
    if command -v pipx >/dev/null 2>&1; then
        log_success "pipx installed successfully"
        return 0
    fi
    
    log_error "Failed to install pipx. Please install manually: pip install pipx"
    return 1
}

# =============================================================================
# INSTALLATION FUNCTIONS
# =============================================================================

# Install shell-gpt via pipx
install_shell_gpt() {
    log_header "Installing shell-gpt via pipx"
    
    # Check if already installed
    if pipx list 2>/dev/null | grep -q "shell-gpt"; then
        log_info "shell-gpt is already installed via pipx"
        
        if prompt_yes_no "Reinstall shell-gpt?" "n"; then
            log_info "Reinstalling shell-gpt..."
            pipx reinstall shell-gpt 2>/dev/null || pipx install --force shell-gpt
        fi
    else
        log_info "Installing shell-gpt..."
        pipx install shell-gpt
    fi
    
    # Verify installation
    if [[ -f "$HOME/.local/share/pipx/venvs/shell-gpt/bin/sgpt" ]]; then
        log_success "shell-gpt installed successfully"
        
        # Show version
        local version=$("$HOME/.local/share/pipx/venvs/shell-gpt/bin/sgpt" --version 2>/dev/null || echo "unknown")
        log_info "Installed version: $version"
    else
        log_error "shell-gpt installation failed"
        return 1
    fi
    
    return 0
}

# Copy wrapper script
install_wrapper() {
    log_header "Installing Wrapper Script"
    
    # Determine source file
    local source_file=""
    if [[ -f "$WRAPPER_SOURCE" ]]; then
        source_file="$WRAPPER_SOURCE"
    elif [[ -f "$(pwd)/bin/sgpt" ]]; then
        source_file="$(pwd)/bin/sgpt"
    elif [[ -f "$HOME/bin/sgpt" ]]; then
        log_info "Wrapper already exists at ~/bin/sgpt"
        source_file="$HOME/bin/sgpt"
    else
        log_error "Could not find wrapper source file"
        return 1
    fi
    
    # Create ~/bin if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating $INSTALL_DIR..."
        mkdir -p "$INSTALL_DIR"
    fi
    
    # Copy wrapper
    log_info "Copying wrapper to $INSTALL_DIR/sgpt..."
    cp "$source_file" "$INSTALL_DIR/sgpt"
    chmod +x "$INSTALL_DIR/sgpt"
    
    log_success "Wrapper installed to $INSTALL_DIR/sgpt"
    return 0
}

# Configure shell PATH
configure_shell_path() {
    log_header "Configuring Shell PATH"
    
    local shell=$(detect_shell)
    local config_file=$(get_shell_config "$shell")
    
    log_info "Detected shell: $shell"
    log_info "Shell config: $config_file"
    
    # Check if ~/bin is already in PATH
    local path_line="export PATH=\"\$HOME/bin:\$PATH\""
    
    if [[ -f "$config_file" ]] && grep -q "$INSTALL_DIR" "$config_file" 2>/dev/null; then
        log_info "PATH already configured in $config_file"
    else
        log_info "Adding $INSTALL_DIR to PATH in $config_file"
        
        # Create backup
        if [[ -f "$config_file" ]]; then
            cp "$config_file" "$config_file.backup.$(date +%Y%m%d%H%M%S)"
        fi
        
        # Add PATH export
        {
            echo ""
            echo "# sgpt-wrapper: Add ~/bin to PATH"
            echo "$path_line"
        } >> "$config_file"
        
        log_success "PATH configured in $config_file"
    fi
    
    # Create alias for convenience
    local alias_line="alias sgpt='$INSTALL_DIR/sgpt'"
    
    if [[ -f "$config_file" ]] && grep -q "alias sgpt=" "$config_file" 2>/dev/null; then
        log_info "sgpt alias already exists"
    else
        {
            echo ""
            echo "# sgpt-wrapper: sgpt alias"
            echo "$alias_line"
        } >> "$config_file"
        
        log_success "Added sgpt alias"
    fi
    
    return 0
}

# =============================================================================
# PROVIDER SETUP
# =============================================================================

# Interactive provider setup
setup_provider() {
    log_header "LLM Provider Setup"
    
    echo "Available providers:"
    echo "  1) OpenAI"
    echo "  2) MiniMax"
    echo "  3) Ollama (local)"
    echo "  4) Together AI"
    echo "  5) Groq"
    echo "  6) Custom"
    echo ""
    
    local choice
    read -p "Select provider [2]: " choice
    choice="${choice:-2}"
    
    local provider=""
    case "$choice" in
        1) provider="openai" ;;
        2) provider="minimax" ;;
        3) provider="ollama" ;;
        4) provider="together" ;;
        5) provider="groq" ;;
        6) provider="custom" ;;
        *) provider="minimax" ;;
    esac
    
    echo "Selected provider: $provider"
    echo ""
    
    # Get API key
    local api_key=""
    local key_var="${PROVIDER_KEY_VARS[$provider]}"
    
    if [[ "$provider" != "ollama" ]]; then
        local prompt_msg="Enter your ${provider} API key"
        if [[ "$provider" == "custom" ]]; then
            prompt_msg="Enter your API key"
        fi
        
        # Check for existing key in environment
        if [[ -n "${!key_var}" ]]; then
            log_info "Found existing $key_var in environment"
            if prompt_yes_no "Use existing API key?" "y"; then
                api_key="${!key_var}"
            fi
        fi
        
        if [[ -z "$api_key" ]]; then
            read -p "$prompt_msg: " -s api_key
            echo ""
        fi
        
        if [[ -z "$api_key" ]]; then
            log_warning "No API key provided. You can set it later in $CONFIG_FILE"
        fi
    else
        # Ollama doesn't need API key
        api_key="not_needed_for_local"
    fi
    
    # Get custom endpoint if needed
    local custom_endpoint=""
    local custom_model=""
    
    if [[ "$provider" == "custom" ]]; then
        prompt_with_default "Enter API base URL" "https://api.example.com/v1" custom_endpoint
        prompt_with_default "Enter model name" "gpt-4" custom_model
    fi
    
    # Get model (allow customization for non-custom)
    if [[ "$provider" != "custom" ]]; then
        local default_model="${PROVIDER_MODELS[$provider]}"
        prompt_with_default "Enter model name" "$default_model" custom_model
    fi
    
    # Write configuration
    write_config "$provider" "$api_key" "$custom_endpoint" "$custom_model"
    
    return 0
}

# Write configuration file
write_config() {
    local provider="$1"
    local api_key="$2"
    local custom_endpoint="$3"
    local custom_model="$4"
    
    log_header "Writing Configuration"
    
    # Create config directory
    mkdir -p "$CONFIG_DIR"
    
    # Determine values based on provider
    local endpoint="${PROVIDER_ENDPOINTS[$provider]:-$custom_endpoint}"
    local model="${PROVIDER_MODELS[$provider]:-$custom_model}"
    local url_var="${PROVIDER_URL_VARS[$provider]}"
    local model_var="${PROVIDER_MODEL_VARS[$provider]}"
    local key_var="${PROVIDER_KEY_VARS[$provider]}"
    
    # Check if config already exists
    local update_mode=false
    if [[ -f "$CONFIG_FILE" ]]; then
        log_info "Updating existing configuration..."
        update_mode=true
    fi
    
    {
        echo "# ============================================================================="
        echo "# sgpt-wrapper Configuration"
        echo "# Generated on $(date)"
        echo "# ============================================================================="
        echo ""
        echo "# ============================================================================="
        echo "# API CONFIGURATION"
        echo "# ============================================================================="
        echo ""
        echo "# OpenAI API configuration"
        if [[ "$provider" == "openai" ]]; then
            echo "${key_var}=${api_key}"
            echo "${url_var}=${endpoint}"
            echo "${model_var}=${model}"
        else
            echo "OPENAI_API_KEY=${OPENAI_API_KEY:-YOUR_OPENAI_API_KEY}"
            echo "OPENAI_API_BASE_URL=https://api.openai.com/v1"
            echo "OPENAI_MODEL=gpt-4"
        fi
        echo ""
        echo "# MiniMax API configuration"
        if [[ "$provider" == "minimax" ]]; then
            echo "${key_var}=${api_key}"
            echo "${url_var}=${endpoint}"
            echo "${model_var}=${model}"
        else
            echo "MINIMAX_API_KEY=${MINIMAX_API_KEY:-YOUR_MINIMAX_API_KEY}"
            echo "MINIMAX_API_BASE_URL=https://api.minimax.io/v1"
            echo "MINIMAX_MODEL=MiniMax-M2.1"
        fi
        echo ""
        echo "# Ollama API configuration (local)"
        if [[ "$provider" == "ollama" ]]; then
            echo "${key_var}=${api_key}"
            echo "${url_var}=${endpoint}"
            echo "${model_var}=${model}"
        else
            echo "OLLAMA_API_KEY=not_needed_for_local"
            echo "OLLAMA_API_BASE_URL=http://localhost:11434/v1"
            echo "OLLAMA_MODEL=llama2"
        fi
        echo ""
        echo "# Together AI API configuration"
        if [[ "$provider" == "together" ]]; then
            echo "${key_var}=${api_key}"
            echo "${url_var}=${endpoint}"
            echo "${model_var}=${model}"
        else
            echo "TOGETHER_API_KEY=${TOGETHER_API_KEY:-YOUR_TOGETHER_API_KEY}"
            echo "TOGETHER_API_BASE_URL=https://api.together.ai/v1"
            echo "TOGETHER_MODEL=meta-llama/Llama-2-70b-chat-hf"
        fi
        echo ""
        echo "# Groq API configuration"
        if [[ "$provider" == "groq" ]]; then
            echo "${key_var}=${api_key}"
            echo "${url_var}=${endpoint}"
            echo "${model_var}=${model}"
        else
            echo "GROQ_API_KEY=${GROQ_API_KEY:-YOUR_GROQ_API_KEY}"
            echo "GROQ_API_BASE_URL=https://api.groq.com/openai/v1"
            echo "GROQ_MODEL=llama2-70b-8192"
        fi
        echo ""
        echo "# ============================================================================="
        echo "# WRAPPER-SPECIFIC SETTINGS"
        echo "# ============================================================================="
        echo ""
        echo "# Selected provider"
        echo "DEFAULT_PROVIDER=$provider"
        echo ""
        echo "# Wrapper-specific system prompt"
        echo "WRAPPER_SYSTEM_PROMPT=You are a helpful AI assistant."
        echo ""
        echo "# Default model for the wrapper"
        echo "WRAPPER_MODEL=$model"
        echo ""
        echo "# ============================================================================="
        echo "# GENERAL SETTINGS"
        echo "# ============================================================================="
        echo ""
        echo "# Cache settings"
        echo "CACHE_ENABLED=true"
        echo "CACHE_PATH=~/.cache/shell_gpt"
        echo ""
        echo "# Display settings"
        echo "SHOW_PROVIDER=true"
        echo "SHOW_MODEL=true"
        echo ""
        echo "# Edit behavior"
        echo "EDITOR=nano"
    } > "$CONFIG_FILE"
    
    # Set proper API key if provided
    if [[ -n "$api_key" ]] && [[ "$api_key" != "not_needed_for_local" ]]; then
        # Use sed to update just the API key line
        sed -i "s|^${key_var}=.*|${key_var}=${api_key}|" "$CONFIG_FILE"
    fi
    
    log_success "Configuration written to $CONFIG_FILE"
}

# =============================================================================
# SHELL INTEGRATION
# =============================================================================

# Configure shell integration
setup_shell_integration() {
    log_header "Shell Integration Setup"
    
    if prompt_yes_no "Enable shell integration (hotkey support)?" "n"; then
        log_info "Shell integration is managed via the sgpt alias"
        log_info "Usage: sgpt -s \"your command\""
        log_info "This will execute commands directly. Use without -s for chat mode."
    fi
    
    return 0
}

# =============================================================================
# MAIN INSTALLER
# =============================================================================

main() {
    echo -e "${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║         sgpt-wrapper Installer                              ║"
    echo "║         Interactive LLM Shell Wrapper Setup                ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check for pipx
    if ! check_pipx; then
        log_error "Cannot proceed without pipx"
        exit 1
    fi
    
    # Install shell-gpt
    if ! install_shell_gpt; then
        log_error "Failed to install shell-gpt"
        exit 1
    fi
    
    # Install wrapper
    if ! install_wrapper; then
        log_error "Failed to install wrapper"
        exit 1
    fi
    
    # Configure shell PATH
    configure_shell_path
    
    # Setup provider (interactive)
    if prompt_yes_no "Configure LLM provider now?" "y"; then
        setup_provider
    else
        log_info "Skipping provider setup. Configure manually in $CONFIG_FILE"
    fi
    
    # Shell integration
    setup_shell_integration
    
    # Final summary
    log_header "Installation Complete!"
    
    echo "Summary:"
    echo "  - shell-gpt: Installed via pipx"
    echo "  - Wrapper:   $INSTALL_DIR/sgpt"
    echo "  - Config:    $CONFIG_FILE"
    echo ""
    
    echo "Next steps:"
    echo "  1. Restart your shell or source your config:"
    echo "     source ~/.bashrc  # for bash"
    echo "     source ~/.zshrc  # for zsh"
    echo ""
    echo "  2. Test the installation:"
    echo "     sgpt --version"
    echo "     sgpt \"Hello, world!\""
    echo ""
    
    echo -e "${GREEN}Happy coding with AI assistance!${NC}"
}

# Run main function
main "$@"
