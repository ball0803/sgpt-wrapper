# sgpt-wrapper-menu-uninstall Learnings

## Implementation Complete

### Features Implemented
1. **API Key Storage System** (`~/.local/share/sgpt/auth.json`)
   - Functions: `load_api_keys()`, `save_api_key()`, `get_api_key()`, `delete_api_key()`, `clear_all_api_keys()`
   - Flags: `--save-key`, `--no-save-key`, `--clear-keys`

2. **--uninstall Flag**
   - Functions: `uninstall_sgpt()`, `confirm_uninstall()`, `cleanup_config()`, `cleanup_keys()`, `cleanup_shell()`
   - Flags: `--uninstall`, `--clean-keys`

3. **--menu/-m Interactive Menu**
   - Functions: `show_menu()`, `menu_change_provider()`, `menu_change_model()`, `menu_update_api_key()`, `menu_view_config()`, `menu_uninstall()`, `run_menu()`

### Testing
- Added 25+ new tests for the new features
- Fixed flag parsing issue: `-m` was conflicting with `--model|-m`
  - Fixed by changing model short flag to `-M` and moving `--menu|-m` before `--model|-M` in case statement
- Fixed variable name issues in tests (UNINSTALL vs UNINSTALL_MODE, MENU vs MENU_MODE, SAVE_KEY vs SAVE_API_KEY)
- All 112 tests pass

### Key Fixes
1. Argument parsing order: `--menu|-m` must come BEFORE `--model|-m` in case statement
2. Short flag for model changed from `-m` to `-M` to avoid conflict with menu
3. Test variable names must match actual variable names in install.sh
