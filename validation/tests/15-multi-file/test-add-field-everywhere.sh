#!/bin/bash
# Test: Ask yo to add a field to a struct and update all usages
# Expected: yo adds the field and updates all call sites

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "add-field-everywhere"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to add a field
OUTPUT=$(run_yo_in_mock_webapp "Add a new field 'created_at: u64' to the User struct in src/models/user.rs. Update the User::new() function to accept this new parameter. Make sure the code compiles after the change.")

# Assert the field was added
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/models/user.rs" "created_at"

# Verify the project still compiles
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
assert_success $?

cleanup_mock_webapp
report_result
