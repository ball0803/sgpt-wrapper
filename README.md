# sgpt-wrapper

A flexible, extensible wrapper for interacting with various LLM providers through a unified CLI interface. Features a sophisticated installer with 23+ provider support, Fish shell integration, and non-interactive installation modes.

## Features

- **23+ LLM Providers**: OpenAI, MiniMax (M2.5 default), Groq, Together AI, Fireworks, DeepSeek, Mistral, and more
- **Fish Shell Support**: Full Fish shell integration with completions
- **Curl One-Liner Install**: curl -sL URL | bash for quick installation
- **Non-Interactive Mode**: --no-interact --provider X --api-key Y for CI/CD
- **Provider Selection Menu**: Interactive dropdown with 23+ providers
- **System Prompt Injection**: Custom prompts via --role or environment variable
- **Local LLM Support**: Ollama, LocalAI, LM Studio, vLLM

## Quick Start

### Curl One-Liner (Recommended)

curl -sL https://raw.githubusercontent.com/ball0803/sgpt-wrapper/main/scripts/install.sh | bash

### Interactive Installer

# Clone and run installer
git clone https://github.com/ball0803/sgpt-wrapper.git
cd sgpt-wrapper
./scripts/install.sh

# Follow the interactive prompts to select your provider

### Non-Interactive (CI/CD)

# Full non-interactive installation
./scripts/install.sh --no-interact \
  --provider minimax \
  --model "MiniMax-M2.5" \
  --api-key "your-api-key" \
  --shell bash

# With auto pipx installation
./scripts/install.sh --no-interact --install-pipx --provider openai --api-key "key"

## Installer Options

./scripts/install.sh [OPTIONS]

OPTIONS:
    --help                  Show this help message
    --dry-run               Show actions without executing
    --no-interact           Disable interactive prompts
    --provider <name>       Set provider directly (e.g., openai, minimax, ollama)
    --model <name>         Set default model
    --api-key <key>        Set API key
    --shell <type>         Set shell type (bash, fish, zsh)
    --install-pipx         Auto-install pipx if not found
    --force                Force overwrite existing configs
    --list-providers       List available providers

ENVIRONMENT VARIABLES (for curl pipe mode):
    SGPT_PROVIDER           Provider name
    SGPT_MODEL             Model name
    SGPT_API_KEY           API key

## Supported Providers (23+)

### International Providers

| Provider | Default Model | Env Variable |
|----------|---------------|--------------|
| **MiniMax** (Default) | MiniMax-M2.5 | MINIMAX_API_KEY |
| OpenAI | gpt-4.5 | OPENAI_API_KEY |
| Groq | llama-3.3-70b-versatile | GROQ_API_KEY |
| Together AI | DeepSeek-R1 | TOGETHER_API_KEY |
| Fireworks AI | DeepSeek-V3.2 | FIREWORKS_API_KEY |
| DeepInfra | Llama-3.3-70B | DEEPINFRA_API_KEY |
| Anyscale | Llama-3.1-70B | ANYSCALE_API_KEY |
| Cerebras | llama-3.1-70b-instruct | CEREBRAS_API_KEY |
| Novita AI | MiniMax-M2.1 | NOVITA_API_KEY |
| Mistral | Mistral-Large-3 | MISTRAL_API_KEY |
| DeepSeek | DeepSeek-V3.2 | DEEPSEEK_API_KEY |

### Chinese Providers

| Provider | Default Model | Env Variable |
|----------|---------------|--------------|
| Zhipu AI (GLM) | GLM-5 | ZHIPU_API_KEY |
| Alibaba (Qwen) | qwen-max | ALIBABA_API_KEY |
| Moonshot (Kimi) | kimi-k2.5 | MOONSHOT_API_KEY |
| iFlytek Spark | spark-v3.5 | IFLYTEK_API_KEY |
| Tencent Hunyuan | hunyuan-turbo | TENCENT_API_KEY |
| Baidu (Ernie) | ernie-5.0 | BAIDU_API_KEY |

### Local Providers

| Provider | Default Model | Notes |
|----------|---------------|-------|
| Ollama | llama3.3 | localhost:11434 |
| LocalAI | llama3.2 | localhost:8080 |
| LM Studio | llama3.3 | localhost:1234 |
| vLLM | llama3.3-70b-instruct | localhost:8000 |

### Custom Provider

Use your own OpenAI-compatible endpoint:

./scripts/install.sh --no-interact \
  --provider Custom \
  --api-key "your-key"

Then manually edit ~/.config/shell_gpt/.sgptrc to set your custom base URL and model.

## Configuration

### Config File Location

~/.config/shell_gpt/.sgptrc

### Config Format

[default]
provider = minimax
api_key = your_api_key_here

[minimax]
model = MiniMax-M2.5
API_BASE_URL = https://api.minimax.io/v1

### Environment Variables

# Provider
export OPENAI_API_KEY="your-key"
export MINIMAX_API_KEY="your-key"
export GROQ_API_KEY="your-key"

# System Prompt
export SGPT_SYSTEM_PROMPT="You are a helpful coding assistant."

# Custom Endpoint
export API_BASE_URL="https://your-endpoint.com/v1"
export DEFAULT_MODEL="your-model"

## Usage Examples

### Basic Query

sgpt "What is the capital of France?"

### Code Generation

sgpt --code "Write a Python function to calculate Fibonacci"

### Custom System Prompt

sgpt --role senior-dev "Explain REST APIs"

### List Providers

./scripts/install.sh --list-providers

## Shell Integration

### Fish Shell

The installer automatically configures Fish shell:

# ~/.config/fish/functions/sgpt.fish is created automatically
sgpt "Hello"

### Bash/Zsh

# Add to ~/.bashrc or ~/.zshrc
alias sgpt='sgpt'
export SGPT_SYSTEM_PROMPT="Your custom prompt"

## Development

### Running Tests

bash tests/run_tests.sh
.sh --filter installer
bash tests/runbash tests/run_tests_tests.sh --coverage

### Adding a Provider

1. Add provider to scripts/providers.json
2. Add configuration function to scripts/install.sh
3. Update templates/sgptrc.template
4. Add tests

## Troubleshooting

### pipx not found

# Auto-install pipx
./scripts/install.sh --install-pipx

# Or manually
pip install pipx

### Connection refused (Local providers)

# Ollama
ollama serve

# LM Studio
# Open LM Studio app and start server

# LocalAI
docker run -d -p 8080:8080 quay.io/go-skynet/local-ai:latest

### Invalid API Key

Check your provider's API key format. Some providers require specific prefixes:

# Groq keys start with gho_
# OpenAI keys start with sk-

### Fish shell issues

# Validate Fish syntax
fish -n ~/.config/fish/config.fish

# Re-run installer for Fish
./scripts/install.sh --shell fish

## License

MIT License - see LICENSE file for details.

## Links

- GitHub: https://github.com/ball0803/sgpt-wrapper
- Issues: https://github.com/ball0803/sgpt-wrapper/issues
