# sgpt-wrapper Enhancement Plan

## TL;DR

> **Quick Summary**: Enhance the shell-gpt wrapper with Fish shell support, curl one-liner installation, improved pipx handling, 20+ LLM providers with interactive selection, comprehensive test suite, and AGENTS.md documentation.

> **Deliverables**:
> - Enhanced `scripts/install.sh` with Fish shell support, curl install mode, and 20+ providers
> - Test suite with unit, integration, and mock-based provider tests
> - AGENTS.md documentation for AI agents
> - Updated `bin/sgpt` wrapper with improved features
> - Updated documentation

> **Estimated Effort**: Large
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Research → Install.sh enhancement → Provider implementation → Test suite → AGENTS.md → Documentation

---

## Context

### Original Request
Enhance the sgpt-wrapper project with:
- Fish shell support (currently only bash/zsh)
- Curl one-liner install option (`curl -sL URL | bash`)
- Better pipx handling (offer to install if missing)
- 20+ OpenAI-compatible LLM providers with dropdown/selection menu
- Comprehensive test suite
- AGENTS.md documentation

### Interview Summary
**Key Discussions**:
- Research completed on 20+ providers with API endpoints and default models
- Config format: INI-style `~/.config/shell_gpt/.sgptrc`
- System prompt via `SGPT_SYSTEM_PROMPT` or `--role` flag
- User's existing config uses MiniMax provider
- Existing files: `bin/sgpt`, `scripts/install.sh`, `templates/sgptrc.template`

**Research Findings**:
- Fish shell config path: `~/.config/fish/config.fish`
- Curl install pattern: Detect curl mode via environment or script header
- Provider API endpoints documented with base URLs and default models
- Major providers: OpenAI, Groq, Together AI, Fireworks AI, DeepInfra, Chinese providers (MiniMax, Zhipu, Baidu, Alibaba, Tencent, Moonshot, iFlytek), local providers (Ollama, LocalAI, LM Studio, vLLM)

### Metis Review
**Identified Gaps** (addressed in plan):
- Need to clarify provider configuration approach (pre-configured vs BYOK)
- Need to define test scope (unit, integration, mock-based)
- Need explicit tiering for 20+ providers (critical vs desirable)
- Need to handle fish function syntax differences from bash

---

## Work Objectives

### Core Objective
Create a production-ready sgpt wrapper with sophisticated installer supporting multiple shells, 20+ LLM providers, and comprehensive test coverage.

### Concrete Deliverables
- `scripts/install.sh`: Enhanced installer with Fish support, curl mode, 20+ providers, better pipx
- `tests/`: Test suite with unit, integration, and provider tests
- `AGENTS.md`: AI agent documentation for the project
- `bin/sgpt`: Enhanced wrapper (if needed based on requirements)
- `README.md`: Updated documentation

### Definition of Done
- [x] Fish shell detected and configured successfully
- [x] Curl one-liner works: `curl -sL <url> | bash`
- [x] pipx installation offered if missing
- [x] All 20+ providers appear in selection menu
- [x] All tests pass (unit ≥80% coverage, integration, mock-based)
- [x] AGENTS.md documents project structure and contribution guidelines

### Must Have
- Fish shell detection and configuration
- Curl one-liner installation support
- pipx installation offering
- 20+ LLM providers with interactive selection
- Comprehensive test suite
- AGENTS.md documentation

### Must NOT Have (Guardrails)
- MUST NOT: Modify existing user configurations without explicit consent
- MUST NOT: Add providers requiring proprietary SDKs (HTTP-based only)
- MUST NOT: Install fish shell itself (only configure for existing installation)
- MUST NOT: Create system-wide installations without sudo (prefer user-space)
- MUST NOT: Test against live provider APIs (use mocks to avoid rate limits/costs)
- MUST NOT: Scope creep to GUI components (CLI-only installer)

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.
> This is NOT conditional — it applies to EVERY task, regardless of test strategy.

### Test Decision
- **Infrastructure exists**: NO - Need to create test framework
- **Automated tests**: Tests-after (tests created after implementation)
- **Framework**: bash + bats (for shell scripting tests)

### Test Infrastructure Setup (First Task)
- [x] Create `tests/test_helper.bash` with common test utilities
- [x] Create `tests/test_installer.sh` for installer tests
- [x] Create `tests/test_wrapper.sh` for wrapper tests
- [x] Create `tests/run_tests.sh` test runner with coverage reporting
- [x] Verify: `bash tests/run_tests.sh` → All tests pass

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

**Example — Fish Detection Verification:**

```
Scenario: Fish shell detection works correctly
  Tool: Bash
  Preconditions: Test environment with fish installed
  Steps:
    1. bash -c 'source scripts/install.sh && detect_fish'
    2. Assert: Exit code 0
    3. Assert: Output contains fish config path
  Expected Result: Fish detection returns success
  Evidence: Test output captured in tests/logs/fish-detection.log

Scenario: Fish config file created with proper syntax
  Tool: Bash
  Preconditions: Fish installed, install.sh runs with fish option
  Steps:
    1. bash scripts/install.sh --shell fish --dry-run
    2. Check: ~/.config/fish/config.fish would contain sgpt function
    3. Assert: Fish syntax is valid (fish -n ~/.config/fish/config.fish)
  Expected Result: Valid fish config generated
  Evidence: Config file output captured

Scenario: Curl install mode works without interaction
  Tool: Bash
  Preconditions: Curl available
  Steps:
    1. curl -sL https://raw.githubusercontent.com/user/repo/main/install.sh | bash -s -- --dry-run
    2. Assert: Exit code 0
    3. Assert: No interactive prompts appear
  Expected Result: Non-interactive curl install succeeds
  Evidence: Terminal output captured

Scenario: pipx installation offered when missing
  Tool: Bash
  Preconditions: pipx not installed
  Steps:
    1. bash scripts/install.sh --check-pipx
    2. Assert: Output contains installation offer
    3. Simulate: Set ACCEPT_PIPX_INSTALL=1
    4. Assert: pipx installation runs
  Expected Result: pipx handling works correctly
  Evidence: Installation log captured
```

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: Research phase - Finalize provider list and API endpoints
├── Task 2: Test infrastructure setup
└── Task 3: AGENTS.md skeleton and project documentation

Wave 2 (After Wave 1):
├── Task 4: Enhance install.sh with Fish shell support
├── Task 5: Add curl one-liner install mode
├── Task 6: Improve pipx handling with installation offer
└── Task 7: Implement provider selection menu (CLI)

Wave 3 (After Wave 2):
├── Task 8: Implement all 20+ providers in installer
├── Task 9: Create comprehensive test suite
└── Task 10: Update README.md and final documentation

Critical Path: Task 1 → Task 4 → Task 7 → Task 8 → Task 9
Parallel Speedup: ~40% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 4, 5, 6, 7, 8 | 2, 3 |
| 2 | None | 9 | 1, 3 |
| 3 | None | None | 1, 2 |
| 4 | 1 | 8 | 5, 6, 7 |
| 5 | 1 | None | 4, 6, 7 |
| 6 | 1 | None | 4, 5, 7 |
| 7 | 1 | 8 | 4, 5, 6 |
| 8 | 4, 7 | 9, 10 | None (depends on menu + fish) |
| 9 | 2, 8 | None | None (final testing) |
| 10 | 8 | None | 9 |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1, 2, 3 | Research + quick for setup |
| 2 | 4, 5, 6, 7 | quick for shell scripting |
| 3 | 8, 9, 10 | quick + writing for docs |

---

## TODOs

> Implementation + Test = ONE Task. Never separate.

- [x] 1. Research Phase - Finalize provider list and API specifications

  **What to do**:
  - Finalize the 20+ provider list with tiering (Tier 1: critical, Tier 2: desirable)
  - Document API endpoints, authentication methods, and default models for each provider
  - Create provider metadata file for installer use
  - Verify API compatibility (OpenAI-compatible format)

  **Must NOT do**:
  - Add providers requiring custom SDKs (HTTP-based APIs only)
  - Include providers that require proprietary authentication

  **Recommended Agent Profile**:
  - **Category**: unspecified-low
    - Reason: Research task with clear deliverables
  - **Skills**: [`general-research`, `official-docs`]
    - `general-research`: Find provider documentation and API specs
    - `official-docs`: Verify API endpoints and authentication

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3)
  - **Blocks**: Tasks 4, 5, 6, 7, 8
  - **Blocked By**: None (can start immediately)

  **References**:
  - Provider research from previous session
  - Shell-gpt repository: https://github.com/TheR1D/shell_gpt
  - Provider documentation links (to be compiled)

  **Acceptance Criteria**:
  - [x] Provider list finalized: 20+ providers with tiering
  - [x] Provider metadata file created: `scripts/providers.json`
  - [x] Each provider has: name, base_url, default_model, auth_format
  - [x] Tier 1 providers: 10 fully-tested (OpenAI, Groq, Together, Fireworks, DeepInfra, Anyscale, Cerebras, Novita, MiniMax, Ollama)
  - [x] Tier 2 providers: 10+ best-effort (Chinese providers + local)

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: Provider list contains required providers
    Tool: Bash
    Preconditions: None
    Steps:
      1. cat scripts/providers.json | jq '.providers | length'
      2. Assert: Count >= 20
      3. jq '.providers[].name' | grep -i "openai\|groq\|together\|fireworks\|deepinfra\|anyscale\|cerebras\|novita\|minimax\|ollama"
      4. Assert: All tier 1 providers present
    Expected Result: Provider list complete
    Evidence: Output saved to tests/logs/provider-list.log
  ```

  **Commit**: NO (part of Wave 1)

- [x] 2. Test Infrastructure Setup

  **What to do**:
  - Create `tests/` directory structure
  - Create `tests/test_helper.bash` with common test utilities
  - Create `tests/test_installer.sh` for installer tests
  - Create `tests/test_wrapper.sh` for wrapper tests
  - Create `tests/run_tests.sh` test runner
  - Setup bats or shelltest for test execution

  **Must NOT do**:
  - Create tests for unimplemented features
  - Modify existing source files

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Standard test setup with clear patterns
  - **Skills**: []
    - No specific skills needed for test scaffolding

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3)
  - **Blocks**: Task 9 (test execution)
  - **Blocked By**: None

  **References**:
  - bats-core: https://github.com/bats-core/bats-core
  - Shell testing patterns from similar projects

  **Acceptance Criteria**:
  - [x] `tests/` directory exists with structure
  - [x] `tests/run_tests.sh` is executable
  - [x] `bash tests/run_tests.sh --help` → Shows usage
  - [x] Test helper has: `assert_equal`, `assert_success`, `assert_failure`, `mock_*
  - [x] Tests directory has at least placeholder tests for installer and wrapper

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: Test infrastructure is properly set up
    Tool: Bash
    Preconditions: None
    Steps:
      1. ls -la tests/
      2. ls -la tests/*.sh
      3. bash tests/run_tests.sh --help
      4. Assert: Help output displayed
    Expected Result: Test infrastructure exists and responds
    Evidence: Directory listing and help output

  Scenario: Test helper functions are available
    Tool: Bash
    Preconditions: Test helper created
    Steps:
      1. source tests/test_helper.bash
      2. type assert_equal
      3. Assert: Function exists
    Expected Result: Helper functions loadable
    Evidence: Function output
  ```

  **Commit**: NO (part of Wave 1)

- [x] 3. Create AGENTS.md Skeleton

  **What to do**:
  - Create `AGENTS.md` with project overview for AI agents
  - Document project structure and file purposes
  - Document CLI commands and their usage
  - Document configuration file format
  - Document contribution guidelines for AI agents
  - Document provider addition process

  **Must NOT do**:
  - Write human-only documentation (use README.md for that)
  - Include implementation details that change frequently

  **Recommended Agent Profile**:
  - **Category**: writing
    - Reason: Documentation writing task
  - **Skills**: []
    - Standard documentation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - Existing projects with AGENTS.md (OpenCode, etc.)
  - Project structure from ls -la

  **Acceptance Criteria**:
  - [x] AGENTS.md exists and is valid markdown
  - [x] Contains: Project overview section
  - [x] Contains: Directory structure section
  - [x] Contains: CLI commands section
  - [x] Contains: Configuration section
  - [x] Contains: Provider addition guidelines
  - [x] Contains: Contribution guidelines for AI agents

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: AGENTS.md is valid and contains required sections
    Tool: Bash
    Preconditions: AGENTS.md created
    Steps:
      1. cat AGENTS.md | grep -E "^#"
      2. Assert: Contains "Project Overview"
      3. Assert: Contains "Directory Structure"
      4. Assert: Contains "CLI Commands"
      5. Assert: Contains "Configuration"
      6. Assert: Contains "Providers"
    Expected Result: All required sections present
    Evidence: Section list output
  ```

  **Commit**: NO (part of Wave 1)

- [x] 4. Enhance Install.sh with Fish Shell Support

  **What to do**:
  - Add Fish shell detection function
  - Create Fish config generation for sgpt
  - Add Fish function installation to `~/.config/fish/functions/`
  - Handle Fish-specific syntax for environment variables
  - Support Fish completions
  - Detect Fish version (3.x+) for compatibility

  **Must NOT do**:
  - Install fish shell itself
  - Modify fish config without user consent
  - Use bash-specific syntax in fish functions

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Shell scripting enhancement task
  - **Skills**: []
    - Standard shell scripting

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 2
  - **Blocks**: Task 8 (provider menu needs fish support)
  - **Blocked By**: Task 1

  **References**:
  - Fish shell documentation: https://fishshell.com/docs/
  - Fish config syntax: `set -gx VARIABLE value`
  - Fish functions: `~/.config/fish/functions/`

  **Acceptance Criteria**:
  - [x] `detect_fish()` function added to install.sh
  - [x] `install_fish_config()` function generates valid fish syntax
  - [x] Fish function file created: `~/.config/fish/functions/sgpt.fish`
  - [x] Fish completion file created: `~/.config/fish/completions/sgpt.fish`
  - [x] Fish detection works when fish is installed but not current shell
  - [x] `fish -n ~/.config/fish/config.fish` → No syntax errors
  - [x] Tests: Fish detection and config generation pass

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: Fish shell is properly detected
    Tool: Bash
    Preconditions: Fish installed on system
    Steps:
      1. source scripts/install.sh
      2. detect_fish
      3. Assert: Exit code 0
      4. Assert: Output contains FISH_VERSION or config path
    Expected Result: Fish detection succeeds
    Evidence: Output saved to tests/logs/fish-detection.log

  Scenario: Fish config has valid syntax
    Tool: Bash
    Preconditions: Fish installed
    Steps:
      1. Generate fish config: install_fish_config --dry-run > /tmp/fish_config.fish
      2. fish -n /tmp/fish_config.fish
      3. Assert: Exit code 0 (no syntax errors)
    Expected Result: Valid fish syntax
    Evidence: fish output captured

  Scenario: Fish sgpt function is created correctly
    Tool: Bash
    Preconditions: Fish functions directory exists
    Steps:
      1. install_fish_functions --dry-run
      2. Assert: Function contains ' argparse ' or proper argument parsing
      3. Assert: Function calls correct python/poetry command
    Expected Result: Valid fish function
    Evidence: Function output saved
  ```

  **Commit**: YES (Wave 2 complete)
  - Message: `feat(installer): add fish shell support`
  - Files: `scripts/install.sh`
  - Pre-commit: `bash tests/test_installer.sh --filter fish`

- [x] 5. Add Curl One-Liner Install Mode

  **What to do**:
  - Add curl detection to identify when running from pipe
  - Create non-interactive mode for curl install
  - Support environment variables for configuration
  - Add `--dry-run` flag for testing
  - Add `--verify` flag to validate script signature
  - Support HTTPS-only sources

  **Must NOT do**:
  - Run in interactive mode when detecting curl pipe
  - Require user input in curl mode
  - Execute without user awareness of what will be installed

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Shell scripting enhancement
  - **Skills**: []
    - Standard scripting

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 2
  - **Blocks**: None
  - **Blocked By**: Task 1

  **References**:
  - Curl documentation: https://curl.se/docs/
  - Install script security best practices

  **Acceptance Criteria**:
  - [x] `is_curl_mode()` detects running from pipe
  - [x] `is_interactive()` returns false in curl mode
  - [x] Environment variables accepted: `SGPT_PROVIDER`, `SGPT_MODEL`, `SGPT_API_KEY`
  - [x] `--dry-run` flag works in both modes
  - [x] `--verify` flag validates script integrity
  - [x] `curl -sL <url> | bash -s -- --dry-run` → No errors
  - [x] Tests: Curl mode detection and non-interactive flow

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: Curl install mode works non-interactively
    Tool: Bash
    Preconditions: Curl available
    Steps:
      1. curl -sL https://raw.githubusercontent.com/user/repo/main/install.sh | bash -s -- --check-mode
      2. Assert: Exit code 0
      3. Assert: No "Enter your choice" prompts in output
    Expected Result: Non-interactive execution
    Evidence: Output captured

  Scenario: Environment variables work in curl mode
    Tool: Bash
    Preconditions: Script supports env vars
    Steps:
      1. export SGPT_PROVIDER=openai && export SGPT_MODEL=gpt-4o
      2. source scripts/install.sh --dry-run
      3. Assert: Config would use specified provider/model
    Expected Result: Env vars applied
    Evidence: Config output

  Scenario: Dry run mode shows what would be installed
    Tool: Bash
    Preconditions: None
    Steps:
      1. bash scripts/install.sh --dry-run
      2. Assert: Output contains "Would install" or similar
      3. Assert: No actual file modifications
    Expected Result: Dry run shows actions
    Evidence: Output saved
  ```

  **Commit**: YES (Wave 2 complete)
  - Message: `feat(installer): add curl one-liner install mode`
  - Files: `scripts/install.sh`
  - Pre-commit: `bash tests/test_installer.sh --filter curl`

- [x] 6. Improve pipx Handling

  **What to do**:
  - Detect if pipx is installed
  - Offer interactive installation if missing
  - Support automatic installation with `ACCEPT_PIPX_INSTALL=1`
  - Support multiple package managers (pip, apt, brew, dnf, pacman)
  - Provide helpful error messages for each failure case
  - Verify pipx installation succeeded

  **Must NOT do**:
  - Install pipx without user consent (unless ACCEPT_PIPX_INSTALL=1)
  - Break existing pipx installations
  - Require sudo unless explicitly requested

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Shell scripting enhancement
  - **Skills**: []
    - Standard scripting

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 2
  - **Blocks**: None
  - **Blocked By**: Task 1

  **References**:
  - pipx documentation: https://pypa.github.io/pipx/
  - pipx installation guide

  **Acceptance Criteria**:
  - [x] `check_pipx()` detects pipx existence
  - [x] `offer_pipx_install()` prompts user (interactive mode)
  - [x] `ACCEPT_PIPX_INSTALL=1` skips prompt and installs
  - [x] Supports: `pip install pipx`, `apt install pipx`, `brew install pipx`
  - [x] `install_pipx()` succeeds when package manager available
  - [x] `verify_pipx()` confirms installation worked
  - [x] Tests: pipx detection and installation scenarios

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: Missing pipx is detected
    Tool: Bash
    Preconditions: pipx not installed
    Steps:
      1. source scripts/install.sh
      2. check_pipx
      3. Assert: Exit code 1 (not found)
      4. Assert: Output contains "pipx not found"
    Expected Result: pipx missing detected
    Evidence: Output captured

  Scenario: pipx installation offer is displayed
    Tool: Bash
    Preconditions: pipx not installed
    Steps:
      1. source scripts/install.sh
      2. offer_pipx_install
      3. Assert: Output contains "Would you like to install pipx"
    Expected Result: Installation offer shown
    Evidence: Output captured

  Scenario: Automatic pipx installation works
    Tool: Bash
    Preconditions: pipx not installed, ACCEPT_PIPX_INSTALL=1
    Steps:
      1. ACCEPT_PIPX_INSTALL=1 install_pipx --dry-run
      2. Assert: Output contains installation command
      3. Assert: No actual installation (dry-run)
    Expected Result: Installation would proceed
    Evidence: Command output
  ```

  **Commit**: YES (Wave 2 complete)
  - Message: `feat(installer): improve pipx handling with installation offer`
  - Files: `scripts/install.sh`
  - Pre-commit: `bash tests/test_installer.sh --filter pipx`

- [x] 7. Implement Provider Selection Menu (CLI)

  **What to do**:
  - Create interactive CLI menu for provider selection
  - Support numbered selection (1-N)
  - Display provider information (name, description, default model)
  - Support keyboard navigation (arrow keys if possible)
  - Provide search/filter capability
  - Store selection in config file

  **Must NOT do**:
  - Require GUI components
  - Add providers not in provider metadata file
  - Use non-standard CLI libraries

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Shell scripting UI task
  - **Skills**: []
    - Standard CLI scripting

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 2
  - **Blocks**: Task 8 (provider implementation)
  - **Blocked By**: Task 1

  **References**:
  - bash select pattern: `select item in list; do ... done`
  - whiptail or dialog for enhanced UI (optional)

  **Acceptance Criteria**:
  - [x] `select_provider()` function exists
  - [x] Menu displays all providers from `scripts/providers.json`
  - [x] User can select by number
  - [x] `select_provider` returns selected provider name
  - [x] Invalid selection shows error and reprompts
  - [x] Works in both interactive and non-interactive modes
  - [x] Tests: Menu display and selection flow

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: Provider menu displays all providers
    Tool: Bash
    Preconditions: Provider metadata exists
    Steps:
      1. source scripts/install.sh
      2. source scripts/providers.json (or jq parse)
      3. select_provider --dry-run
      4. Assert: All 20+ providers appear in output
      5. Assert: Provider count >= 20
    Expected Result: All providers shown
    Evidence: Menu output captured

  Scenario: Provider selection works correctly
    Tool: Bash
    Preconditions: Provider menu available
    Steps:
      1. echo "1" | source scripts/install.sh && select_provider
      2. Assert: Selected provider is first in list
      3. Assert: Selection returned to caller
    Expected Result: Selection processed
    Evidence: Output captured

  Scenario: Invalid selection shows error
    Tool: Bash
    Preconditions: Provider menu available
    Steps:
      1. echo "999" | source scripts/install.sh && select_provider
      2. Assert: Error message displayed
      3. Assert: Prompt reappears
    Expected Result: Invalid input handled
    Evidence: Error handling output
  ```

  **Commit**: YES (Wave 2 complete)
  - Message: `feat(installer): add provider selection menu`
  - Files: `scripts/install.sh`
  - Pre-commit: `bash tests/test_installer.sh --filter provider-menu`

- [x] 8. Implement All 20+ Providers in Installer

  **What to do**:
  - Implement provider configuration functions for all 20+ providers
  - Create API endpoint validation for each provider
  - Add authentication helper functions
  - Support both API key and token-based auth
  - Handle provider-specific configurations
  - Add provider documentation URLs

  **Must NOT do**:
  - Include providers that require custom SDKs
  - Store API keys in plaintext (use existing sgpt config)
  - Test against live APIs

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Implementation task with clear patterns
  - **Skills**: []
    - Standard scripting

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 3
  - **Blocks**: Tasks 9, 10
  - **Blocked By**: Tasks 4, 7

  **References**:
  - Provider metadata from Task 1
  - Provider documentation links

  **Tier 1 Providers (Critical - Must Implement)**:
  1. OpenAI: `https://api.openai.com/v1`, model: `gpt-4o`
  2. Azure OpenAI: `https://{resource}.openai.azure.com/openai/`, model: `gpt-4o`
  3. Groq: `https://api.groq.com/openai/v1`, model: `llama-3.3-70b-versatile`
  4. Together AI: `https://api.together.ai/v1`, model: `meta-llama/Llama-3.3-70B-Instruct`
  5. Fireworks AI: `https://api.fireworks.ai/inference/v1`, model: `llama-v3-70b-instruct`
  6. DeepInfra: `https://api.deepinfra.com/v1/openai`, model: `Llama-2-70b-chat-hf`
  7. Anyscale: `https://api.endpoints.anyscale.com/v1`, model: `Llama-2-7b-chat-hf`
  8. Cerebras: `https://api.cerebras.ai/v1`, model: `llama-3.1-70b-instruct`
  9. Novita AI: `https://api.novita.ai/v3/openai`, model: `llama-3.1-70b-instruct`
  10. MiniMax: `https://api.minimax.io/v1`, model: `MiniMax-M2.1`
  11. Ollama: `http://localhost:11434/v1`, model: `llama3`

  **Tier 2 Providers (Desirable - User Requested)**:
  12. Mistral: `https://api.mistral.ai/v1`, model: `mistral-large-latest`
  13. DeepSeek: `https://api.deepseek.com/v1`, model: `deepseek-chat`
  14. Zhipu AI (GLM): `https://open.bigmodel.cn/api/paas/v4`, model: `glm-4`
  15. Alibaba Tongyi (Qwen): `https://dashscope.aliyuncs.com/compatible-mode/v1`, model: `qwen-max`
  16. Moonshot AI (Kimi): `https://api.moonshot.cn/v1`, model: `kimi-chat`
  17. iFlytek Spark: `https://spark-api.xf-yun.com/v1`, model: `spark-v3.5`
  18. Tencent Hunyuan: `https://hunyuan.cloud.tencent.com/openapi`, model: `hunyuan-pro`
  19. Baidu Wenxin: `https://aip.baidubce.com/rpc/2.0/ai_custom/v1`, model: `ernie-4.0`
  20. LocalAI: `http://localhost:8080/v1`, model: `llama-2-7b`
  21. LM Studio: `http://localhost:1234/v1`, model: `llama-3-8b-instruct`
  22. vLLM: `http://localhost:8000/v1`, model: `llama-2-7b`

  **Acceptance Criteria**:
  - [x] All Tier 1 providers implemented with `configure_*` functions
  - [x] All Tier 2 providers implemented with `configure_*` functions
  - [x] `configure_openai()` creates valid config with OpenAI endpoint
  - [x] `configure_groq()` creates valid config with Groq endpoint
  - [x] `configure_minimax()` creates valid config with MiniMax endpoint
  - [x] `configure_ollama()` creates valid config with local Ollama
  - [x] `configure_zhipu()` creates valid config with Zhipu AI
  - [x] `configure_baidu()` creates valid config with Baidu Wenxin
  - [x] `configure_alibaba()` creates valid config with Alibaba Tongyi
  - [x] `configure_tencent()` creates valid config with Tencent Hunyuan
  - [x] `configure_moonshot()` creates valid config with Moonshot AI
  - [x] `configure_iflytek()` creates valid config with iFlytek Spark
  - [x] `configure_localai()` creates valid config with LocalAI
  - [x] `configure_lmstudio()` creates valid config with LM Studio
  - [x] `configure_vllm()` creates valid config with vLLM
  - [x] Provider tests: Mock-based config generation tests pass

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: All Tier 1 providers have configuration functions
    Tool: Bash
    Preconditions: Provider functions implemented
    Steps:
      1. grep -E "configure_(openai|groq|together|fireworks|deepinfra|anyscale|cerebras|novita|minimax|ollama)" scripts/install.sh
      2. Assert: All 11 functions found
    Expected Result: All Tier 1 functions exist
    Evidence: Function list output

  Scenario: OpenAI configuration generates valid config
    Tool: Bash
    Preconditions: configure_openai function exists
    Steps:
      1. configure_openai --api-key="sk-test" --dry-run
      2. Assert: Output contains "OPENAI_API_KEY=sk-test"
      3. Assert: Output contains "API_BASE_URL=https://api.openai.com/v1"
    Expected Result: Valid OpenAI config
    Evidence: Config output

  Scenario: MiniMax configuration generates valid config
    Tool: Bash
    Preconditions: configure_minimax function exists
    Steps:
      1. configure_minimax --api-key="minimax-test" --dry-run
      2. Assert: Output contains "API_BASE_URL=https://api.minimax.io/v1"
      3. Assert: Output contains "DEFAULT_MODEL=MiniMax-M2.1"
    Expected Result: Valid MiniMax config
    Evidence: Config output

  Scenario: Ollama local provider configured correctly
    Tool: Bash
    Preconditions: configure_ollama function exists
    Steps:
      1. configure_ollama --dry-run
      2. Assert: Output contains "API_BASE_URL=http://localhost:11434/v1"
      3. Assert: No API key required for local
    Expected Result: Valid Ollama config
    Evidence: Config output
  ```

  **Commit**: YES (Wave 3 complete)
  - Message: `feat(installer): implement all 20+ LLM providers`
  - Files: `scripts/install.sh`
  - Pre-commit: `bash tests/test_installer.sh --filter provider-config`

- [x] 8b. Add Parameter Mode Support (Non-Interactive CLI)

  **What to do**:
  - Add `--no-interact` flag to disable all interactive prompts
  - Add `--provider <name>` flag to set provider directly
  - Add `--model <name>` flag to set model
  - Add `--api-key <key>` flag to set API key
  - Add `--shell <bash|fish|zsh>` flag to set shell
  - Add `--install-pipx` flag to auto-install pipx
  - Add `--help` flag showing all available options
  - Missing parameters use sensible defaults
  - Validate all provided parameters

  **Parameter Specification**:
  ```bash
  ./install.sh --no-interact \
    --provider minimax \
    --model "MiniMax M2.1" \
    --api-key "your-api-key" \
    --shell fish
  ```

  **Supported Flags**:
  | Flag | Description | Required | Default |
  |------|-------------|----------|---------|
  | `--no-interact` | Disable interactive prompts | No | false (interactive) |
  | `--provider` | LLM provider name | No | Prompt if not set |
  | `--model` | Model name | No | Provider default |
  | `--api-key` | API key for provider | No | Prompt if not set |
  | `--shell` | Shell type (bash/fish/zsh) | No | Detect current |
  | `--install-pipx` | Auto-install pipx | No | false |
  | `--dry-run` | Show actions without executing | No | false |
  | `--help` | Show usage information | No | N/A |

  **Must NOT do**:
  - Require any parameter that has a valid default
  - Fail silently on invalid parameter values
  - Ignore `--no-interact` flag

  **Recommended Agent Profile**:
  - **Category**: quick
    - Reason: Shell scripting enhancement
  - **Skills**: []
    - Standard CLI argument parsing

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 3
  - **Blocks**: None
  - **Blocked By**: Task 1

  **References**:
  - getopt/argparse for bash
  - Common CLI flag patterns

  **Acceptance Criteria**:
  - [x] `--no-interact` flag disables all prompts
  - [x] `--provider minimax` sets MiniMax provider
  - [x] `--model "MiniMax M2.1"` sets the model
  - [x] `--api-key "key"` sets the API key
  - [x] `--shell fish` sets fish shell
  - [x] `--install-pipx` triggers pipx installation
  - [x] `--dry-run` shows actions without executing
  - [x] `--help` displays comprehensive usage
  - [x] Missing parameters use defaults
  - [x] Invalid provider shows error (not silent failure)
  - [x] Tests: All flag combinations work correctly

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: --no-interact flag works
    Tool: Bash
    Preconditions: None
    Steps:
      1. bash scripts/install.sh --no-interact --dry-run
      2. Assert: No "Enter your choice" prompts in output
      3. Assert: Exit code 0
    Expected Result: Non-interactive execution
    Evidence: Output captured

  Scenario: Provider can be set via --provider flag
    Tool: Bash
    Preconditions: None
    Steps:
      1. bash scripts/install.sh --no-interact --provider openai --dry-run
      2. Assert: Output contains "provider=openai"
      3. Assert: No provider prompt appears
    Expected Result: Provider set via flag
    Evidence: Output captured

  Scenario: All parameters work together
    Tool: Bash
    Preconditions: None
    Steps:
      1. bash scripts/install.sh \
           --no-interact \
           --provider minimax \
           --model "MiniMax M2.1" \
           --api-key "test-key" \
           --shell bash \
           --dry-run
      2. Assert: Output contains all provided values
      3. Assert: Exit code 0
    Expected Result: All flags applied
    Evidence: Output captured

  Scenario: --help displays all options
    Tool: Bash
    Preconditions: None
    Steps:
      1. bash scripts/install.sh --help
      2. Assert: Output contains "--no-interact"
      3. Assert: Output contains "--provider"
      4. Assert: Output contains "--model"
      5. Assert: Output contains "--api-key"
      6. Assert: Output contains "--shell"
    Expected Result: Help shows all flags
    Evidence: Help output

  Scenario: Invalid provider shows error
    Tool: Bash
    Preconditions: None
    Steps:
      1. bash scripts/install.sh --no-interact --provider invalid-provider --dry-run
      2. Assert: Exit code 1
      3. Assert: Error message about invalid provider
    Expected Result: Invalid input rejected
    Evidence: Error output
  ```

  **Commit**: YES (Wave 3)
  - Message: `feat(installer): add non-interactive parameter mode`
  - Files: `scripts/install.sh`
  - Pre-commit: `bash tests/test_installer.sh --filter parameter-mode`

- [x] 9. Create Comprehensive Test Suite

  **What to do**:
  - Write unit tests for all installer functions
  - Write mock-based tests for provider configuration
  - Write integration tests for installer workflow
  - Write tests for Fish shell integration
  - Write tests for curl install mode
  - Achieve ≥80% code coverage on installer functions

  **Must NOT do**:
  - Test against live provider APIs (use mocks)
  - Modify source code just to increase coverage
  - Skip tests that catch real bugs

  **Recommended Agent Profile**:
  - **Category**: unspecified-low
    - Reason: Testing task with clear deliverables
  - **Skills**: []
    - Standard testing

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 3
  - **Blocks**: None (final task)
  - **Blocked By**: Tasks 2, 8

  **References**:
  - bats-core testing framework
  - Mock patterns in shell scripting

  **Test Categories**:
  1. **Unit Tests**:
     - `test_detect_fish()`
     - `test_is_curl_mode()`
     - `test_check_pipx()`
     - `test_select_provider()`
     - `test_configure_openai()`
     - `test_configure_groq()`
     - etc.

  2. **Integration Tests**:
     - `test_full_install_interactive()`
     - `test_full_install_curl_mode()`
     - `test_full_install_with_fish()`
     - `test_upgrade_existing_installation()`

  3. **Mock-Based Provider Tests**:
     - Mock API responses for each provider
     - Validate config generation without API calls
     - Test error handling with mock failures

  **Acceptance Criteria**:
  - [x] All installer functions have unit tests
  - [x] ≥80% code coverage on `scripts/install.sh`
  - [x] All Fish shell tests pass
  - [x] All curl mode tests pass
  - [x] All provider configuration tests pass
  - [x] `bash tests/run_tests.sh` → All tests PASS
  - [x] Test output shows coverage report

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: All tests pass successfully
    Tool: Bash
    Preconditions: Test suite created
    Steps:
      1. bash tests/run_tests.sh
      2. Assert: Exit code 0
      3. Assert: "All tests passed" or similar summary
    Expected Result: Tests succeed
    Evidence: Test output saved to tests/logs/test-run.log

  Scenario: Code coverage meets threshold
    Tool: Bash
    Preconditions: Coverage enabled
    Steps:
      1. bash tests/run_tests.sh --coverage
      2. Assert: Coverage >= 80%
      3. Assert: No critical functions untested
    Expected Result: Coverage threshold met
    Evidence: Coverage report

  Scenario: Provider mock tests validate config generation
    Tool: Bash
    Preconditions: Mock tests exist
    Steps:
      1. bash tests/run_tests.sh --filter mock-provider
      2. Assert: All 20 provider mocks pass
      3. Assert: No API calls made
    Expected Result: Mock tests pass
    Evidence: Mock test output
  ```

  **Commit**: YES (Wave 3 complete)
  - Message: `test(installer): add comprehensive test suite with 80% coverage`
  - Files: `tests/`
  - Pre-commit: `bash tests/run_tests.sh`

- [x] 10. Update README.md and Final Documentation

  **What to do**:
  - Update README.md with all new features
  - Document Fish shell usage
  - Document curl one-liner installation
  - Document provider list and selection
  - Document pipx handling
  - Add troubleshooting section

  **Must NOT do**:
  - Include implementation details (keep in code comments)
  - Duplicate AGENTS.md content

  **Recommended Agent Profile**:
  - **Category**: writing
    - Reason: Documentation update
  - **Skills**: []
    - Standard documentation

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 3
  - **Blocks**: None (final task)
  - **Blocked By**: Task 8

  **Acceptance Criteria**:
  - [x] README.md updated with Fish shell instructions
  - [x] README.md documents curl one-liner: `curl -sL <url> | bash`
  - [x] README.md lists all 20+ providers
  - [x] README.md documents pipx installation handling
  - [x] README.md has troubleshooting section
  - [x] Documentation tested for accuracy

  **Agent-Executed QA Scenarios**:
  ```
  Scenario: README contains all required sections
    Tool: Bash
    Preconditions: README updated
    Steps:
      1. cat README.md | grep -E "^##"
      2. Assert: Contains "Installation"
      3. Assert: Contains "Fish Shell"
      4. Assert: Contains "Providers"
      5. Assert: Contains "Troubleshooting"
    Expected Result: All sections present
    Evidence: Section list
  ```

  **Commit**: YES (final commit)
  - Message: `docs: update README with all features and providers`
  - Files: `README.md`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 4 | `feat(installer): add fish shell support` | `scripts/install.sh` | `bash tests/test_installer.sh --filter fish` |
| 5 | `feat(installer): add curl one-liner install mode` | `scripts/install.sh` | `bash tests/test_installer.sh --filter curl` |
| 6 | `feat(installer): improve pipx handling` | `scripts/install.sh` | `bash tests/test_installer.sh --filter pipx` |
| 7 | `feat(installer): add provider selection menu` | `scripts/install.sh` | `bash tests/test_installer.sh --filter provider-menu` |
| 8 | `feat(installer): implement all 20+ LLM providers` | `scripts/install.sh` | `bash tests/test_installer.sh --filter provider-config` |
| 9 | `test(installer): add comprehensive test suite` | `tests/` | `bash tests/run_tests.sh` |
| 10 | `docs: update README with all features` | `README.md` | `cat README.md` |

---

## Success Criteria

### Verification Commands
```bash
# Provider list check
jq '.providers | length' scripts/providers.json  # Should be >= 20

# Test suite
bash tests/run_tests.sh  # All tests PASS

# Fish detection
bash scripts/install.sh --check-fish  # Should detect fish if installed

# Curl mode
curl -sL https://raw.githubusercontent.com/user/repo/main/install.sh | bash -s -- --check  # Should work non-interactively

# Provider selection
bash scripts/install.sh --select-provider --dry-run  # Should show menu
```

### Final Checklist
- [x] All "Must Have" present
- [x] All "Must NOT Have" absent
- [x] All tests pass (≥80% coverage)
- [x] Fish shell configured correctly
- [x] Curl one-liner works non-interactively
- [x] pipx handling offers installation
- [x] 20+ providers in selection menu
- [x] AGENTS.md documents project
- [x] README.md updated with all features

---

## Decisions Needed

### 1. Provider Scope (USER CONFIRMED)
**Selected**: Tier 1 + Top Chinese providers
- Tier 1 (11): OpenAI, Azure, Groq, Together AI, Fireworks, DeepInfra, Anyscale, Cerebras, Novita, MiniMax, Ollama
- Chinese/Tier 2 (9+): Zhipu (GLM), Alibaba (Qwen), Moonshot (Kimi), DeepSeek, Mistral, iFlytek (Spark), Tencent (Hunyuan), Baidu (Wenxin), LocalAI, LM Studio, vLLM

### 2. Git Hosting (USER CONFIRMED)
**Selected**: GitHub Releases
- URL pattern: `https://github.com/ball0803/sgpt-wrapper/releases/latest/download/install.sh`
- Versioned releases with tag matching
- SHA256 checksum verification

### 3. Review Mode (USER CONFIRMED)
**Selected**: High Accuracy Review - Submitting to Momus for verification

Please answer these questions to proceed with the implementation plan.