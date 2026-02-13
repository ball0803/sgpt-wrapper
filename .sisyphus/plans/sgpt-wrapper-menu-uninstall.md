# sgpt-wrapper Enhancement Plan: Menu, Uninstall & API Key Storage

## TL;DR

> **Quick Summary**: Add `--uninstall`, `--menu/-m`, and API key storage features to the installer for complete configuration management.

> **Deliverables**:
> - `--uninstall` flag to remove all sgpt-wrapper files
> - `--menu/-m` flag for interactive configuration menu
> - API key storage in `~/.local/share/sgpt/auth.json`
> - Save/load API keys per provider for easy switching

> **Estimated Effort**: Medium
> **Parallel Execution**: NO (sequential)
> **Critical Path**: API key storage → Menu system → Uninstall

---

## Context

### Original Request
Add these features to the installer:
1. `--uninstall` flag to remove all sgpt-wrapper related files
2. `-m`/`--menu` flag for interactive menu to change config
3. Save API keys to `~/.local/share/sgpt/auth.json` for provider switching

### Current State
- `scripts/install.sh` exists with all core features
- Config stored in `~/.config/shell_gpt/.sgptrc`
- No unified uninstall or API key management

### User Requirements
- User explicitly requested:
  - `--uninstall`: Remove all related files
  - `--menu/-m`: Interactive menu to change provider, model, config
  - API key storage: Save keys per provider, reuse when switching

---

## Work Objectives

### Core Objective
Add complete configuration management to the installer with uninstall capability and persistent API key storage.

### Concrete Deliverables
- Updated `scripts/install.sh` with:
  - `--uninstall` flag and function
  - `--menu/-m` flag and interactive menu
  - API key storage system in `~/.local/share/sgpt/auth.json`

### Definition of Done
- [x] `--uninstall` removes all related files
- [x] `--menu/-m` shows interactive configuration menu
- [x] API keys saved per provider in auth.json
- [x] Switching providers retains API keys
- [x] All tests pass

### Must Have
- `--uninstall` flag
- `--menu/-m` flag
- API key storage per provider

### Must NOT Have (Guardrails)
- MUST NOT: Remove unrelated user files
- MUST NOT: Store API keys in plain text without user consent
- MUST NOT: Break existing configuration

---

## Implementation Details

### 1. API Key Storage (`~/.local/share/sgpt/auth.json`)

```json
{
  "providers": {
    "openai": {
      "api_key": "sk-xxx",
      "updated_at": "2026-02-13T14:00:00Z"
    },
    "minimax": {
      "api_key": "xxx",
      "updated_at": "2026-02-13T14:00:00Z"
    }
  }
}
```

**Functions:**
- `load_api_keys()` - Load keys from auth.json
- `save_api_key(provider, api_key)` - Save key for provider
- `get_api_key(provider)` - Get saved key for provider
- `delete_api_key(provider)` - Delete key for provider

**Behavior:**
- If API key provided via `--api-key`, save it
- If switching provider, prompt to use saved key or enter new
- `--clear-keys` to delete all saved keys

### 2. Uninstall Function

**Files to remove:**
- `~/.config/shell_gpt/.sgptrc` (config)
- `~/.local/share/sgpt/auth.json` (API keys)
- `~/.local/share/pipx/venvs/sgpt` (pipx venv)
- `~/.config/fish/functions/sgpt.fish` (Fish function)
- `~/.config/fish/completions/sgpt.fish` (Fish completion)
- Shell rc entries (optional cleanup)

**Functions:**
- `uninstall_sgpt()` - Main uninstall function
- `confirm_uninstall()` - Confirm before uninstall
- `cleanup_config()` - Remove config directory
- `cleanup_keys()` - Remove API keys
- `cleanup_shell()` - Remove shell integration

**Behavior:**
- `--uninstall` flag triggers uninstall mode
- Shows what will be removed
- Requires confirmation (unless `--force`)
- `--uninstall --clean-keys` also removes API keys

### 3. Interactive Menu (`--menu/-m`)

**Menu Options:**
```
╔══════════════════════════════════════════╗
║       sgpt-wrapper Configuration        ║
╠══════════════════════════════════════════╣
║  1. Change Provider                   ║
║  2. Change Model                       ║
║  3. Update API Key                     ║
║  4. View Current Config                ║
║  5. Uninstall sgpt-wrapper             ║
║  6. Exit                               ║
╚══════════════════════════════════════════╝
```

**Functions:**
- `show_menu()` - Display main menu
- `menu_change_provider()` - Change provider with key selection
- `menu_change_model()` - Change model
- `menu_update_api_key()` - Update API key
- `menu_view_config()` - Show current config
- `menu_uninstall()` - Trigger uninstall

**Behavior:**
- `-m` or `--menu` flag triggers menu mode
- Numbered selection
- Back to previous menu option
- Quit with confirmation

---

## Execution Plan

### Task 1: API Key Storage System

**What to do**:
- Create `~/.local/share/sgpt/` directory
- Implement `load_api_keys()`, `save_api_key()`, `get_api_key()`
- Update `--api-key` to auto-save
- Add `--save-key` / `--load-key` flags

**Files modified**: `scripts/install.sh`

### Task 2: --uninstall Flag

**What to do**:
- Add `--uninstall` flag parsing
- Implement uninstall functions
- Add confirmation prompts
- Handle `--clean-keys` flag

**Files modified**: `scripts/install.sh`

### Task 3: --menu/-m Interactive Menu

**What to do**:
- Add `-m`/`--menu` flag parsing
- Implement menu display functions
- Connect to provider/model/key functions
- Handle all menu options

**Files modified**: `scripts/install.sh`

### Task 4: Testing

**What to do**:
- Add tests for API key storage
- Add tests for uninstall
- Add tests for menu

**Files modified**: `tests/test_installer.sh`

---

## Flag Specifications

### New Flags

| Flag | Description | Default |
|------|-------------|---------|
| `-m`, `--menu` | Show interactive configuration menu | false |
| `--uninstall` | Uninstall sgpt-wrapper | false |
| `--clean-keys` | Also remove saved API keys (with --uninstall) | false |
| `--save-key` | Save API key to storage | false |
| `--no-save-key` | Don't save API key | false |

### Updated Flags

| Flag | Updated Behavior |
|------|-----------------|
| `--api-key` | Now auto-saves to auth.json |
| `--provider` | Prompts to use saved key if exists |

---

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/shell_gpt/.sgptrc` | Main config |
| `~/.local/share/sgpt/auth.json` | API key storage |
| `~/.local/share/pipx/venvs/sgpt` | pipx venv |
| `~/.config/fish/functions/sgpt.fish` | Fish function |
| `~/.config/fish/completions/sgpt.fish` | Fish completion |

---

## Acceptance Criteria

### API Key Storage
- [x] `~/.local/share/sgpt/auth.json` created on first key save
- [x] `--api-key` saves key automatically
- [x] Switching providers shows saved key option
- [x] `--clear-keys` removes all saved keys

### Uninstall
- [x] `--uninstall` shows what will be removed
- [x] Confirmation required (unless `--force`)
- [x] Removes: config, shell integration, pipx venv
- [x] `--clean-keys` also removes auth.json

### Menu
- [x] `-m`/`--menu` shows interactive menu
- [x] Change provider works with saved keys
- [x] Change model works
- [x] Update API key works
- [x] View config works
- [x] Uninstall accessible from menu

### Tests
- [x] All new functions have tests
- [x] `bash tests/run_tests.sh` passes
