#!/bin/bash
# Test: Ask yo to rename a struct across files
# Expected: yo renames User to AppUser in all files

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "rename-across-files"

# Reset mock_webapp scratch
reset_mock_webapp

# Count occurrences of 'User' before
BEFORE_COUNT=$(grep -r "struct User\|User::\|use.*User\|-> User\|<User>" "$MOCK_WEBAPP_SCRATCH/src" 2>/dev/null | wc -l)
echo "Before: $BEFORE_COUNT occurrences of User" >> "$TEST_LOG"

# Ask yo to rename User to AppUser
OUTPUT=$(run_yo_in_mock_webapp "Rename the User struct to AppUser across the entire codebase. Update all imports, usages, and references. Make sure the code still compiles.")

# Assert files were modified
assert_git_dirty "$MOCK_WEBAPP_SCRATCH"

# Assert AppUser now exists
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/models/user.rs" "struct AppUser"

# Verify the project still compiles
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
assert_success $?

cleanup_mock_webapp
report_result
