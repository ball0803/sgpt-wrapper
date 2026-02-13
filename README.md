# sgpt-wrapper

<p align="center">
  <img src="https://img.shields.io/badge/LLM-Providers-23%2B-blue?style=for-the-badge&color=4F46E5" alt="23+ LLM Providers">
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Fish%20%7C%20Zsh-black?style=for-the-badge&color=4F46E5" alt="Shell Support">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-purple?style=for-the-badge" alt="Platform">
</p>

A flexible, extensible wrapper for interacting with various LLM providers through a unified CLI interface. Features a sophisticated installer with 23+ provider support, interactive configuration menu, and per-provider API key storage.

## ✨ Features

| Feature | Description |
|---------|-------------|
| **23+ LLM Providers** | OpenAI, MiniMax (default), Groq, Together AI, Fireworks, DeepSeek, Mistral, and more |
| **Interactive Menu** | `--menu` / `-m` for easy provider switching and config management |
| **API Key Storage** | Keys saved per-provider in `~/.local/share/sgpt/auth.json` |
| **One-Liner Install** | `curl -sL URL | bash` for quick setup |
| **CI/CD Ready** | Full non-interactive mode with `--no-interact` |
| **Local LLM Support** | Ollama, LocalAI, LM Studio, vLLM |
| **Fish Shell** | Full integration with completions |

## 🚀 Quick Start

### One-Liner Install (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/ball0803/sgpt-wrapper/main/scripts/install.sh | bash
```

### Interactive Installer

```bash
git clone https://github.com/ball0803/sgpt-wrapper.git
cd sgpt-wrapper
./scripts/install.sh
```

### Non-Interactive (CI/CD)

Use curl to install directly, or clone for local development:

```bash
# Basic non-interactive install (requires provider + api-key for cloud)
curl -sL https://raw.githubusercontent.com/ball0803/sgpt-wrapper/main/scripts/install.sh | bash -s -- \
  --no-interact \
  --provider minimax \
  --api-key "your-api-key"

# With custom model
curl -sL https://raw.githubusercontent.com/ball0803/sgpt-wrapper/main/scripts/install.sh | bash -s -- \
  --no-interact \
  --provider openai \
  --model gpt-4 \
  --api-key "your-api-key"

# Local providers don't need api-key (Ollama, LocalAI, LM Studio, vLLM)
curl -sL https://raw.githubusercontent.com/ball0803/sgpt-wrapper/main/scripts/install.sh | bash -s -- \
  --no-interact \
  --provider ollama
```

**Required in non-interactive mode**:
- `--provider` (always required)
- `--api-key` (required for cloud providers, not local)

**Use `--force`** to skip validation in non-interactive mode.

## 📖 Usage

```bash
# Basic query
sgpt "What is the capital of France?"

# Code generation
sgpt --code "Write a Python function to calculate Fibonacci"

# Custom system prompt
sgpt --role senior-dev "Explain REST APIs"

# Interactive configuration menu (self-contained - no install.sh needed)
sgpt --menu

# List available providers
./scripts/install.sh --list-providers

# Uninstall
sgpt --uninstall
```

## ⚙️ Configuration

### Config Location
```
~/.config/shell_gpt/.sgptrc
```

### Config Format
```ini
[default]
provider = minimax
api_key = your_api_key_here

[minimax]
model = MiniMax-M2.5
API_BASE_URL = https://api.minimax.io/v1
```

### API Key Storage
API keys are automatically saved per-provider:
```
~/.local/share/sgpt/auth.json
```

```json
{
  "providers": {
    "openai": { "api_key": "sk-xxx", "updated_at": "..." },
    "minimax": { "api_key": "xxx", "updated_at": "..." }
  }
}
```

## 🛠️ Installer Options

| Flag | Description |
|------|-------------|
| `--help` | Show help message |
| `--dry-run` | Show actions without executing |
| `--no-interact` | Disable interactive prompts |
| `--provider <name>` | Set provider directly |
| `--model <name>` | Set default model |
| `--api-key <key>` | Set API key |
| `--shell <type>` | Set shell type (bash, fish, zsh) |
| `--install-pipx` | Auto-install pipx |
| `--force` | Force overwrite existing configs |
| `--list-providers` | List available providers |
| `--save-key` | Save API key to storage |
| `--no-save-key` | Don't save API key |
| `--clear-keys` | Clear all stored API keys |
| `--uninstall` | Uninstall sgpt-wrapper |
| `--clean-keys` | Remove API keys on uninstall |
| `--menu`, `-m` | Interactive configuration menu |

## ☁️ Supported Providers (23+)

### International Providers
| Provider | Default Model | Env Variable |
|----------|---------------|--------------|
| **MiniMax** (Default) | MiniMax-M2.5 | `MINIMAX_API_KEY` |
| OpenAI | gpt-4.5 | `OPENAI_API_KEY` |
| Groq | llama-3.3-70b-versatile | `GROQ_API_KEY` |
| Together AI | DeepSeek-R1 | `TOGETHER_API_KEY` |
| Fireworks AI | DeepSeek-V3.2 | `FIREWORKS_API_KEY` |
| Mistral | Mistral-Large-3 | `MISTRAL_API_KEY` |
| DeepSeek | DeepSeek-V3.2 | `DEEPSEEK_API_KEY` |
| DeepInfra | Llama-3.3-70B | `DEEPINFRA_API_KEY` |
| Anyscale | Llama-3.1-70B | `ANYSCALE_API_KEY` |
| Cerebras | llama-3.1-70b-instruct | `CEREBRAS_API_KEY` |
| Novita AI | MiniMax-M2.1 | `NOVITA_API_KEY` |

### Chinese Providers
| Provider | Default Model | Env Variable |
|----------|---------------|--------------|
| Zhipu AI (GLM) | GLM-5 | `ZHIPU_API_KEY` |
| Alibaba (Qwen) | qwen-max | `ALIBABA_API_KEY` |
| Moonshot (Kimi) | kimi-k2.5 | `MOONSHOT_API_KEY` |
| iFlytek Spark | spark-v3.5 | `IFLYTEK_API_KEY` |
| Tencent Hunyuan | hunyuan-turbo | `TENCENT_API_KEY` |
| Baidu (Ernie) | ernie-5.0 | `BAIDU_API_KEY` |

### Local Providers
| Provider | Default Model | Endpoint |
|----------|---------------|----------|
| Ollama | llama3.3 | localhost:11434 |
| LocalAI | llama3.2 | localhost:8080 |
| LM Studio | llama3.3 | localhost:1234 |
| vLLM | llama3.3-70b-instruct | localhost:8000 |

## 🐟 Shell Integration

### Fish Shell
Automatically configured by installer:
```fish
sgpt "Hello"
```

### Bash/Zsh
```bash
# Add to ~/.bashrc or ~/.zshrc
alias sgpt='sgpt'
export SGPT_SYSTEM_PROMPT="Your custom prompt"
```

## 🧪 Development

```bash
# Run all tests
bash tests/run_tests.sh

# Run installer tests
bash tests/test_installer.sh

# Test installer
./scripts/install.sh --help
```

## 🔧 Troubleshooting

### pipx not found
```bash
./scripts/install.sh --install-pipx
```

### Connection refused (Local providers)
```bash
# Ollama
ollama serve

# LM Studio
# Open LM Studio app and start server

# LocalAI
docker run -d -p 8080:8080 quay.io/go-skynet/local-ai:latest
```

### Fish shell issues
```bash
fish -n ~/.config/fish/config.fish  # Validate syntax
./scripts/install.sh --shell fish   # Re-run installer
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Links

<p align="center">
  <a href="https://github.com/ball0803/sgpt-wrapper">
    <img src="https://img.shields.io/badge/GitHub-Repo-black?style=for-the-badge&logo=github" alt="GitHub">
  </a>
  <a href="https://github.com/ball0803/sgpt-wrapper/issues">
    <img src="https://img.shields.io/badge/Issues-Report-red?style=for-the-badge&logo=github" alt="Issues">
  </a>
</p>
