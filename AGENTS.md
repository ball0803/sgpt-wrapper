# AGENTS.md - Development Guide for sgpt-wrapper

## Project Overview

**sgpt-wrapper** is a shell-based GPT wrapper that provides a unified CLI interface for interacting with 23+ LLM providers.

This project, `sgpt-wrapper`, is a shell-based GPT wrapper designed to simplify interaction with large language models (LLMs) through a command-line interface. It provides an enhanced installer and configuration system to support multiple LLM providers, making it easy to switch between different AI services without modifying core logic. The wrapper is intended for developers and power users who prefer CLI workflows and need flexibility in provider selection.

### Key Features
- **23+ LLM Providers**: OpenAI, MiniMax (default), Groq, Together AI, Fireworks, DeepSeek, Mistral, and more
- **Interactive Installer**: Provider selection, API key management, shell integration
- **Config Management**: ~/.config/shell_gpt/.sgptrc
- **API Key Storage**: ~/.local/share/sgpt/auth.json (per-provider)
- **New Features**:
  - `--uninstall` flag to remove all sgpt-wrapper files
  - `--menu/-m` interactive configuration menu
  - `--save-key` / `--no-save-key` / `--clear-keys` for API key management

---

## CLI Commands

- `sgpt [query]`: Send a query to the default LLM provider. Supports `--provider` to override default.

- `sgpt --role <role> [query]`: Set system prompt via `--role` flag or `SGPT_SYSTEM_PROMPT` environment variable.

- `sgpt --list-providers`: List all available LLM providers configured in `providers.json`.

- `sgpt --install`: Run the installer to set up configuration directories and initialize `providers.json`.

- `sgpt --config`: Open or edit the configuration file (`~/.config/shell_gpt/.sgptrc`).

- `sgpt --code [query]`: Generate code output.

---

## Configuration

Configuration is stored in `~/.config/shell_gpt/.sgptrc` using INI-style format:

```ini
[default]
provider = openai
api_key = your_api_key_here

[openai]
model = gpt-4

[minimax]
model = MiniMax-M2.5
API_BASE_URL = https://api.minimax.io/v1
```

Each provider section contains provider-specific settings. The `[default]` section sets global defaults.

---

## Directory Structure

```
sgpt-wrapper/
├── AGENTS.md              # This file - DO NOT COMMIT
├── README.md              # Project documentation (commit this)
├── bin/
│   └── sgpt              # Main wrapper script
├── scripts/
│   ├── install.sh        # Installer with 23+ provider support
│   └── providers.json    # Provider metadata
├── templates/
│   └── sgptrc.template  # Config template
├── tests/
│   ├── run_tests.sh     # Test runner
│   ├── test_helper.bash # Test utilities
│   ├── test_installer.sh # Installer tests
│   └── test_wrapper.sh  # Wrapper tests
└── .sisyphus/           # Planning directory - DO NOT COMMIT
    ├── plans/           # Work plans
    ├── notepads/        # Learning documentation
    └── boulder.json    # Active work tracking
```

---

## Development Setup

### Prerequisites
- Bash 4+
- jq (for JSON parsing)
- pipx (for package management)
- Git

### Running Tests
```bash
# Run all tests
bash tests/run_tests.sh

# Run installer tests only
bash tests/test_installer.sh

# Run wrapper tests
bash tests/test_wrapper.sh
```

### Testing the Installer
```bash
# Show help
./scripts/install.sh --help

# Dry run
./scripts/install.sh --dry-run --provider openai --api-key test-key

# List providers
./scripts/install.sh --list-providers

# Interactive mode
./scripts/install.sh
```

---

## Adding a New Provider

### Steps to Add a Provider

1. **Add to providers.json**:
   ```bash
   # Edit scripts/providers.json
   # Add new provider entry with name, default_model, api_base_url, etc.
   ```

2. **Add configure function in install.sh**:
   ```bash
   # Add configure_<provider>() function
   # Follow pattern of configure_openai(), configure_minimax(), etc.
   ```

3. **Add to configure_provider() dispatch**:
   ```bash
   # Add case statement in configure_provider() function
   ```

4. **Add tests**:
   ```bash
   # Add test_configure_<provider>() in tests/test_installer.sh
   ```

5. **Update templates**:
   ```bash
   # Update templates/sgptrc.template if needed
   ```

---

## Using .sisyphus for Planning (CRITICAL)

This project uses .sisyphus/ for work planning and tracking.

### Directory Structure
- `.sisyphus/plans/` - Work plan files (Prometheus format)
- `.sisyphus/notepads/` - Learning documentation
- `.sisyphus/boulder.json` - Active work tracking

### Workflow
1. Create plan in `.sisyphus/plans/`
2. Work tracked via boulder.json
3. Notepad stores learnings between sessions

---

## Git Workflow

### Commit Message Format
```
type(scope): description

Types: feat, fix, docs, chore, refactor, test
```

### ⚠️ IMPORTANT - DO NOT COMMIT

**NEVER commit these files to git:**
- `.sisyphus/` - Local planning tools
- `AGENTS.md` - This file

These are LOCAL DEVELOPMENT TOOLS ONLY and should remain in your working directory but NEVER committed to git.

### Why?
- `.sisyphus/` contains planning notes, not project code
- `AGENTS.md` is development guidance, not project documentation
- Keeps git history clean for collaborators

### If You Accidentally Commit
Use git filter-repo to rewrite history:
```bash
git filter-repo --path .sisyphus --path AGENTS.md --invert-paths --force
```

---

## Features Documentation

### Installer Flags

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
| `--save-key` | Save API key to storage (default) |
| `--no-save-key` | Don't save API key |
| `--clear-keys` | Clear all stored API keys |
| `--uninstall` | Uninstall sgpt-wrapper |
| `--clean-keys` | Also remove API keys (with --uninstall) |
| `--menu`, `-m` | Show interactive configuration menu |

### Environment Variables
- `SGPT_PROVIDER` - Provider name
- `SGPT_MODEL` - Model name
- `SGPT_API_KEY` - API key

---

## Troubleshooting

### pipx not found
```bash
./scripts/install.sh --install-pipx
```

### Fish shell issues
```bash
fish -n ~/.config/fish/config.fish  # Validate syntax
```

### Connection refused (Local providers)
- Ollama: `ollama serve`
- LM Studio: Open app and start server
- LocalAI: `docker run -d -p 8080:8080 quay.io/go-skynet/local-ai:latest`

---

## Resources

- GitHub: https://github.com/ball0803/sgpt-wrapper
- Issues: https://github.com/ball0803/sgpt-wrapper/issues

---

## Contribution Guidelines

AI agents should follow these guidelines when contributing:

- **Commit Messages**: Use imperative mood: `feat: add new provider`, `fix: resolve config loading bug`, `docs: update README`

- **Testing**: Always run test suite before committing. Ensure all tests pass.

- **Formatting**: Use consistent indentation (bash: 4 spaces), no trailing whitespace, and follow existing code style.

- **Documentation**: Update `README.md` for new features or changes to configuration. Update `AGENTS.md` for development workflow changes.

- **Verification**: After changes, verify tests pass and run `./scripts/install.sh --help` to ensure installer works.
