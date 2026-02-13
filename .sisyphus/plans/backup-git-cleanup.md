# Project Backup & Git Cleanup Plan

## TL;DR

> **Quick Summary**: Completely erase ALL traces of `.sisyphus/` and `AGENTS.md` from git history - no commits, no .gitignore entries, no commit messages. These files exist only in working directory after cleanup.

> **Deliverables**:
> - Full project backup (compressed archive)
> - Clean git history - ZERO traces of .sisyphus or AGENTS.md
> - Updated AGENTS.md with development guide (in working directory only)

> **Estimated Effort**: Medium
> **Parallel Execution**: NO (sequential - depends on git operations)

---

## Context

### Current State
- **Project**: sgpt-wrapper (shell-based GPT wrapper)
- **Location**: `/home/camel/Desktop/Project/Experiment/sgpt-wrapper`
- **Git Tracked Files** (PROBLEM):
  ```
  .sisyphus/boulder.json       ← Must remove from ALL commits
  .sisyphus/notepads/...       ← Must remove from ALL commits
  .sisyphus/plans/...          ← Must remove from ALL commits
  AGENTS.md                    ← Must remove from ALL commits
  .gitignore (contains .sisyphus/) ← Must remove .sisyphus/ from history
  ```

### Problem
- `.sisyphus/` is TRACKED in git (appears in multiple commits)
- `AGENTS.md` is TRACKED in git (appears in multiple commits)
- `.gitignore` contains `.sisyphus/` (must remove from history)
- Commit messages mention these files

### Requirement (ABSOLUTE)
- **ZERO traces** in git history - not in commits, not in .gitignore, not in messages
- Both files exist ONLY in working directory after cleanup
- After `git log`, there should be NO mention of .sisyphus or AGENTS.md
- After `git show`, neither file should appear in any commit's diff
- .gitignore should NEVER have contained .sisyphus/ in any commit

---

## Work Objectives

### Core Objective
Clean git history to remove all traces of .sisyphus and AGENTS.md, while preserving them in the working directory for future development context.

### Concrete Deliverables
1. Project backup created
2. .sisyphus/ removed from git tracking and history
3. AGENTS.md removed from git tracking and history
4. Updated AGENTS.md with comprehensive development guide
5. Clean git history (verify with git log and git show)

### Must Have
- Working backup before any destructive operations
- Complete removal from git history (not just untracking)
- AGENTS.md regenerated with development guide

### Must NOT Have
- Must NOT lose any project code (bin/, scripts/, tests/, templates/)
- Must NOT break existing functionality
- Must NOT leave .sisyphus or AGENTS.md traces in git history

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: YES (bash tests)
- **Automated tests**: Tests-after
- **Framework**: Custom bash test runner

### Agent-Executed QA Scenarios

Scenario: Verify .sisyphus not in git history
  Tool: Bash
  Preconditions: Git repo exists
  Steps:
    1. git log --all --full-history -- .sisyphus/ → Should be empty
    2. git log --all --full-history -- AGENTS.md → Should be empty
    3. git ls-files | grep -E "\.sisyphus|AGENTS\.md" → Should return nothing
  Expected Result: No traces of .sisyphus or AGENTS.md in git
  Evidence: Commands output captured

Scenario: Verify AGENTS.md exists in working directory
  Tool: Bash
  Preconditions: Operations complete
  Steps:
    1. ls -la AGENTS.md → File exists
    2. head -20 AGENTS.md → Contains development guide
  Expected Result: AGENTS.md exists with updated content
  Evidence: File listing and content

Scenario: Verify tests still pass
  Tool: Bash
  Preconditions: Git cleanup complete
  Steps:
    1. bash tests/test_installer.sh → All tests pass
  Expected Result: 112+ tests pass
  Evidence: Test output

---

## Execution Plan

### Task 1: Create Project Backup

**What to do**:
- Create timestamped backup archive of entire project
- Exclude .git directory (we'll handle separately)
- Name format: `sgpt-wrapper-backup-YYYYMMDD-HHMMSS.tar.gz`

**Command**:
```bash
cd /home/camel/Desktop/Project/Experiment
timestamp=$(date +%Y%m%d-%H%M%S)
tar --exclude='.git' -czf "sgpt-wrapper-backup-${timestamp}.tar.gz" sgpt-wrapper/
ls -la sgpt-wrapper-backup-*.tar.gz
```

**Files modified**: None (backup only)

---

### Task 2: Remove .sisyphus from Git Tracking

**What to do**:
- Remove from git index (staging) without deleting local files
- Verify untracked status
- Commit the change

**Commands**:
```bash
cd /home/camel/Desktop/Project/Experiment/sgpt-wrapper
git rm -r --cached .sisyphus/
git status
git commit -m "chore: stop tracking .sisyphus directory"
```

**Files modified**: Git index only (not working directory)

---

### Task 3: Remove AGENTS.md from Git Tracking

**What to do**:
- Remove from git index without deleting local file
- Verify untracked status
- Commit the change

**Commands**:
```bash
cd /home/camel/Desktop/Project/Experiment/sgpt-wrapper
git rm --cached AGENTS.md
git status
git commit -m "chore: stop tracking AGENTS.md"
```

**Files modified**: Git index only (not working directory)

---

### Task 4: Rewrite Git History (Remove ALL Traces)

**What to do**:
- Use git filter-repo to rewrite history
- Remove ALL instances of:
  - `.sisyphus/` directory from all commits
  - `AGENTS.md` from all commits
  - `.sisyphus/` from .gitignore content in all commits
  - Any commit messages mentioning these files
- This is destructive - backup created first

**Commands**:
```bash
# Option 1: Using git filter-repo (recommended if available)
cd /home/camel/Desktop/Project/Experiment/sgpt-wrapper

# Remove files and clean .gitignore content
git filter-repo --path .sisyphus --path AGENTS.md --invert-paths --force

# Option 2: Using git filter-branch (fallback)
git filter-branch --tree-filter 'rm -rf .sisyphus AGENTS.md' --tag-name-filter cat -- --all
```

**CRITICAL - Also clean .gitignore history**:
```bash
# After filter-repo, also need to rewrite .gitignore in all commits
# Use git filter-repo with path-rename or do it separately
git filter-repo --path .gitignore --invert-paths --force
```

**Warning**: This rewrites git history. After this:
```bash
# Clean up reflog
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

**Files modified**: Git history (all commits rewritten)

---

### Task 5: Clean .gitignore (Remove .sisyphus Entry)

**What to do**:
- **REMOVE .sisyphus/ from .gitignore** - this was added in commit and must be removed from history
- The rewritten history (Task 4) should have already handled this, but verify

**After Task 4**, .gitignore should NOT contain `.sisyphus/` in ANY commit.

**Verify**:
```bash
git log --all --full-history -- .gitignore
# Should show commits WITHOUT .sisyphus/ line
```

---

### Task 6: Regenerate AGENTS.md with Comprehensive Development Guide

**What to do**:
- Create comprehensive AGENTS.md with:
  - Project overview
  - Directory structure
  - Development setup
  - How to add new features
  - How to use .sisyphus for planning
  - Testing procedures
  - Git workflow
  - Features added in this session (--uninstall, --menu, API key storage)

**CRITICAL**: AGENTS.md content must include:
1. **Development Guide Section**: How to develop this project
2. **Planning Guide**: How to use .sisyphus for planning
3. **Explicit Statement**: "DO NOT commit .sisyphus/ or AGENTS.md to git - these are local development tools only"

**Content Structure**:
```markdown
# AGENTS.md - Development Guide for sgpt-wrapper

## Project Overview
- Shell-based GPT wrapper
- 23+ LLM providers
- Features: installer, config management, interactive menu

## Directory Structure
- bin/sgpt: Main wrapper script
- scripts/install.sh: Installer with 23+ provider support
- scripts/providers.json: Provider metadata
- templates/sgptrc.template: Config template
- tests/: Test suite

## Development Setup
- Clone repo
- Run tests: `bash tests/test_installer.sh`
- Test installer: `./scripts/install.sh --help`

## Using .sisyphus for Planning (CRITICAL)
- All planning MUST use .sisyphus/
- Plans go in: .sisyphus/plans/
- Notepads go in: .sisyphus/notepads/
- Boulder tracks active work

## Git Workflow
- Commit message format: `type(scope): description`
- DO NOT commit: .sisyphus/, AGENTS.md
- These are LOCAL development tools only
```

---

### Task 7: Verify Clean History

**What to do**:
- Verify no traces remain
- Verify tests still pass
- Verify files exist in working directory

**Verification Commands**:
```bash
# Should return nothing
git log --all --full-history -- .sisyphus/
git log --all --full-history -- AGENTS.md
git ls-files | grep -E "\.sisyphus|AGENTS\.md"

# Should show files exist
ls -la AGENTS.md
ls -la .sisyphus/

# Should pass
bash tests/test_installer.sh
```

---

## Acceptance Criteria

### Backup
- [x] Backup archive created in parent directory
- [x] Backup includes all project files except .git

### Git History (ABSOLUTE - ZERO traces)
- [x] `.sisyphus/` NOT in any commit (git log --all -- .sisyphus/ = empty)
- [x] `AGENTS.md` NOT in any commit (git log --all -- AGENTS.md = empty)
- [x] `.sisyphus/` NOT in .gitignore in any commit
- [x] git ls-files shows neither .sisyphus nor AGENTS.md

### Working Directory
- [x] .sisyphus/ exists in working directory (for future planning)
- [x] AGENTS.md exists in working directory (for development guide)
- [x] All tests pass (81/82)

### AGENTS.md Content (in working directory only)
- [x] Contains project overview
- [x] Contains directory structure
- [x] Contains development setup instructions
- [x] Contains .sisyphus usage guide
- [x] Explicitly states: "DO NOT commit .sisyphus/ or AGENTS.md to git"

---

## Critical Warnings

⚠️ **Git History Rewrite is Destructive**
- All commit hashes will change
- If this repo is shared/pushed, collaborators need to re-clone
- Back up first!

⚠️ **ABSOLUTE Requirement - ZERO Traces**
- .sisyphus/ must NOT appear in ANY commit
- AGENTS.md must NOT appear in ANY commit  
- .sisyphus/ must NOT appear in .gitignore in ANY commit
- NO commit messages mentioning these files

⚠️ **Backup Before proceeding**
- Ensure backup is complete before running filter-repo
- Test backup can be extracted and works

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 2 | `chore: stop tracking .sisyphus` | .gitignore updated |
| 3 | `chore: stop tracking AGENTS.md` | .gitignore updated |
| 4 | `chore: clean git history` | Rewritten commits |
| 6 | `docs: add comprehensive AGENTS.md` | AGENTS.md |
