# Plan: Install Script Refactor & sgpt Wrapper Enhancement

## TL;DR

> **Quick Summary**: Refactor install.sh to be interactive by default, move --menu to sgpt wrapper, add --uninstall/--help/--version to wrapper, and add --force requirement for non-interactive mode.

> **Deliverables**:
> - Install script: Interactive by default, no --menu flag
> - sgpt wrapper: Add --menu, --uninstall, --help, --version flags
> - Non-interactive mode: Require --force for missing required fields

> **Estimated Effort**: Medium
> **Parallel Execution**: NO (sequential - install.sh then sgpt wrapper)

---

## Context

### Current State
- `install.sh`: Interactive by default with --no-interact flag
- `install.sh`: Has --menu/-m flag
- `sgpt`: Basic wrapper with limited flags

### User Requirements
1. **Install script**: Interactive BY DEFAULT (no flag needed)
2. **Move --menu**: Remove from install.sh, add to sgpt wrapper
3. **Add --uninstall**: Add to sgpt wrapper
4. **Add --help injection**: Wrapper should show helpful info
5. **Add --version**: Show wrapper version + sgpt version
6. **Non-interactive validation**: Require --force if missing required fields (api key, etc.)

---

## Work Objectives

### Core Objective
Refactor the installation experience to be user-friendly while adding wrapper capabilities.

### Concrete Deliverables
1. Updated install.sh - interactive by default, no menu flag
2. Updated sgpt wrapper - add --menu, --uninstall, --help, --version
3. Validation logic - --force required in non-interactive mode without required fields

### Must Have
- Install script works interactively without any flags
- sgpt wrapper has all new flags
- Non-interactive mode validates required fields
- --force bypasses validation

### Must NOT Have
- --menu in install.sh
- Install running without required fields in non-interactive mode (without --force)

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: YES (bash tests)
- **Automated tests**: Tests-after
- **Framework**: Custom bash test runner

### Agent-Executed QA Scenarios

Scenario: Install script runs interactively by default
  Tool: Bash
  Preconditions: None
  Steps:
    1. timeout 2 ./scripts/install.sh <<< "q" → Shows interactive prompts
  Expected Result: Interactive menu appears without flags
  Evidence: Output shows provider selection

Scenario: Install script with --no-interact without required fields fails
  Tool: Bash
  Preconditions: No api-key provided
  Steps:
    1. ./scripts/install.sh --no-interact --provider openai → Should fail
    2. echo $? → Non-zero exit code
  Expected Result: Error about missing required fields
  Evidence: Exit code

Scenario: Install script with --no-interact --force works without api-key
  Tool: Bash
  Preconditions: No api-key, --force flag
  Steps:
    1. ./scripts/install.sh --no-interact --provider openai --force → Should proceed
  Expected Result: Installation proceeds
  Evidence: Output shows installation

Scenario: sgpt wrapper has --menu flag
  Tool: Bash
  Preconditions: sgpt installed
  Steps:
    1. sgpt --menu → Shows configuration menu
  Expected Result: Interactive menu displays
  Evidence: Menu output

Scenario: sgpt wrapper has --uninstall flag
  Tool: Bash
  Preconditions: sgpt installed
  Steps:
    1. sgpt --uninstall --dry-run → Shows uninstall preview
  Expected Result: Uninstall preview displayed
  Evidence: Output shows what will be removed

Scenario: sgpt wrapper has --version flag
  Tool: Bash
  Preconditions: sgpt installed
  Steps:
    1. sgpt --version → Shows version info
  Expected Result: Version output with wrapper + sgpt versions
  Evidence: Version string displayed

---

## Execution Plan

### Task 1: Refactor install.sh - Interactive by Default

**What to do**:
- Change logic: IF NOT --no-interact THEN interactive mode
- Remove --menu/-m flag entirely from install.sh
- Keep all other existing functionality

**Files modified**: scripts/install.sh

---

### Task 2: Add --menu to sgpt Wrapper

**What to do**:
- Add --menu flag parsing to bin/sgpt
- Call install.sh --menu when --menu is used
- Or implement menu directly in wrapper

**Files modified**: bin/sgpt

---

### Task 3: Add --uninstall to sgpt Wrapper

**What to do**:
- Add --uninstall flag parsing to bin/sgpt
- Call install.sh --uninstall when --uninstall is used
- Support --dry-run for preview
- Support --clean-keys for removing API keys

**Files modified**: bin/sgpt

---

### Task 4: Add --help to sgpt Wrapper

**What to do**:
- Add --help flag parsing to bin/sgpt
- Show helpful information about available commands
- Include usage examples

**Files modified**: bin/sgpt

---

### Task 5: Add --version to sgpt Wrapper

**What to do**:
- Add --version flag parsing to bin/sgpt
- Show: wrapper version + sgpt version (from package or config)
- Format: "sgpt-wrapper vX.X.X | sgpt vY.Y.Y"

**Files modified**: bin/sgpt

---

### Task 6: Add Non-Interactive Validation with --force

**What to do**:
- In install.sh: Check required fields (provider, api-key) in non-interactive mode
- If missing required fields AND NOT --force: Exit with error
- If --force: Proceed anyway (user takes responsibility)

**Required fields**:
- provider (required)
- api_key (required for cloud providers, not for local like ollama)

**Files modified**: scripts/install.sh

---

### Task 7: Update Tests

**What to do**:
- Update test_installer.sh for new behavior
- Add tests for new wrapper flags

**Files modified**: tests/test_installer.sh

---

### Task 8: Update README with Non-Interactive Examples

**What to do**:
- Add clear examples showing --no-interactive usage
- Show required fields for non-interactive mode
- Document --force flag behavior

**Add to README**:
```markdown
### Non-Interactive Mode

Without flags, install.sh runs interactively. Use --no-interact for automated installs:

```bash
# Basic non-interactive (requires all fields)
./scripts/install.sh --no-interact \
  --provider minimax \
  --api-key "your-api-key"

# With model
./scripts/install.sh --no-interact \
  --provider openai \
  --model gpt-4 \
  --api-key "your-api-key"

# Force without api-key (for local providers like Ollama)
./scripts/install.sh --no-interact \
  --provider ollama \
  --force
```

**Required in non-interactive mode**:
- `--provider` (always required)
- `--api-key` (required for cloud providers, not local)

**Use --force to skip validation** in non-interactive mode.
```

**Files modified**: README.md

---

## Acceptance Criteria

### Install Script
- [x] Runs interactively by default (no flags needed)
- [x] --no-interact flag disables interactive mode
- [x] No --menu/-m flag exists (moved to sgpt wrapper)
- [x] --force allows running without required fields in non-interactive mode
- [x] Without --force, non-interactive mode fails if required fields missing

### sgpt Wrapper
- [x] --menu shows configuration menu
- [x] --uninstall shows uninstall options (with --dry-run, --clean-keys)
- [x] --help shows usage information
- [x] --version shows version info

### Tests
- [x] All tests pass
- [x] New functionality covered by tests

### Documentation
- [x] README updated with --no-interactive examples
- [x] --force flag documented

---

## Flag Specifications

### Install Script Changes

| Current | New |
|---------|-----|
| --no-interact (optional) | --no-interact (optional) |
| --menu/-m | REMOVED |
| (new) | --force (allow running without required fields) |

### sgpt Wrapper New Flags

| Flag | Description |
|------|-------------|
| --menu | Show interactive configuration menu |
| --uninstall | Uninstall sgpt-wrapper |
| --help | Show usage information |
| --version | Show version info |

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 1 | refactor: make install.sh interactive by default | install.sh |
| 2-5 | feat: add --menu/--uninstall/--help/--version to sgpt wrapper | bin/sgpt |
| 6 | feat: add --force validation for non-interactive mode | install.sh |
| 7 | test: update tests for new behavior | test_installer.sh |
| 8 | docs: update README with non-interactive examples | README.md |
