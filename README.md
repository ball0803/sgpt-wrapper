# sgpt-wrapper

A flexible, extensible wrapper for interacting with various LLM providers through a unified interface. Designed to support system prompt injection, provider flexibility, and idempotent installation.

## Features

- **System Prompt Injection**: Inject custom system prompts to control model behavior.
- **Provider Flexibility**: Support for multiple LLM providers including OpenAI, MiniMax, Ollama, Together AI, and Groq.
- **Idempotent Installer**: Safe installation that doesn't overwrite existing configurations.
- **Shell Integration**: Hotkey support for quick access from terminal.

## Prerequisites

Before you begin, ensure you have the following installed:

- Python 3.8+
- `pip` (Python package manager)
- `pipx` (for installing CLI tools)
- Shell: `bash`, `zsh`, or `fish`

## Installation

### Quick Start

Install `sgpt-wrapper` globally using `pipx`:

```bash
pipx install sgpt-wrapper
```

### Detailed Steps

1. Clone the repository (if not already done):
   ```bash
   git clone https://github.com/yourusername/sgpt-wrapper.git
   cd sgpt-wrapper
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Install the CLI tool:
   ```bash
   pipx install .
   ```

4. Verify installation:
   ```bash
   sgpt --version
   ```

## Configuration

### Provider Setup

Configure your preferred LLM provider by setting environment variables or using the configuration file.

#### OpenAI

```bash
export OPENAI_API_KEY="your-api-key"
```

#### MiniMax

```bash
export MINIMAX_API_KEY="your-api-key"
```

#### Ollama

```bash
export OLLAMA_BASE_URL="http://localhost:11434"
```

#### Together AI

```bash
export TOGETHER_API_KEY="your-api-key"
```

#### Groq

```bash
export GROQ_API_KEY="your-api-key"
```

### System Prompt Configuration

You can customize the system prompt by setting the `SGPT_SYSTEM_PROMPT` environment variable:

```bash
export SGPT_SYSTEM_PROMPT="You are a helpful assistant that follows instructions precisely."
```

## Usage Examples

### Shell Commands

Use `sgpt` directly in your terminal to generate text:

```bash
sgpt "Write a poem about cats"
```

### Code Generation

Generate code snippets with specific language and context:

```bash
sgpt "Generate a Python function to calculate Fibonacci sequence"
```

### Custom System Prompts

Override the default system prompt with your own:

```bash
SGPT_SYSTEM_PROMPT="You are a senior software engineer. Respond with concise, technical answers." sgpt "Explain how to implement a binary search tree"
```

## Provider Documentation

### OpenAI

- API Key: `OPENAI_API_KEY`
- Model: `gpt-3.5-turbo`, `gpt-4`, etc.

### MiniMax

- API Key: `MINIMAX_API_KEY`
- Model: `abab5.5`, `abab6`, etc.

### Ollama

- Base URL: `OLLAMA_BASE_URL` (default: `http://localhost:11434`)
- Model: `llama3`, `mistral`, etc.

### Together AI

- API Key: `TOGETHER_API_KEY`
- Model: `meta-llama/Meta-Llama-3-8B`, `mistralai/Mistral-7B-Instruct-v0.2`, etc.

### Groq

- API Key: `GROQ_API_KEY`
- Model: `llama3-8b-8192`, `mixtral-8x7b-32768`, etc.

## Shell Integration

### Hotkey Support

Enable hotkey support by adding the following to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.fish/config.fish`):

```bash
# Add to ~/.bashrc or ~/.zshrc
alias sgpt='sgpt-wrapper'

# For hotkey support, add this to your shell profile
# Example: Ctrl+Shift+G to trigger sgpt
bind -x '"\C-\C-g": sgpt-wrapper"
```

### Auto-completion

Install auto-completion for `sgpt`:

```bash
sgpt --install-completion
```

## Troubleshooting

### Common Issues and Solutions

#### 1. `sgpt` command not found

Ensure `pipx` is in your PATH and the installation was successful:

```bash
pipx list
```

If not installed, reinstall:

```bash
pipx install sgpt-wrapper
```

#### 2. API Key not found

Set the appropriate environment variable for your provider:

```bash
export OPENAI_API_KEY="your-api-key"
```

#### 3. Model not found

Verify the model name is correct for your provider. Check the provider's documentation for available models.

#### 4. Connection refused (Ollama)

Ensure Ollama is running and the base URL is correct:

```bash
ollama serve
```

#### 5. Permission denied

Ensure you have execute permissions for the `sgpt` binary:

```bash
chmod +x /path/to/sgpt
```

## Contributing

We welcome contributions! Here's how you can help:

### How to Extend or Modify

1. Fork the repository.
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes.
4. Write tests for your changes (if applicable).
5. Commit your changes:
   ```bash
   git commit -m "feat: add your feature"
   ```
6. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
7. Open a pull request.

### Code Style

Follow the existing code style. We use `black` for formatting and `flake8` for linting.

### Testing

Run tests before submitting a pull request:

```bash
pytest tests/
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.