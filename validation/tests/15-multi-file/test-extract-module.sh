#!/bin/bash
# Test: Ask yo to extract code into a new module
# Expected: yo creates a new module and updates imports

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "extract-module"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to create a new errors module
OUTPUT=$(run_yo_in_mock_webapp "Create a new module src/errors.rs that defines an AppError enum with variants NotFound, InvalidInput, and Unauthorized. Add it to lib.rs. Make sure the code compiles.")

# Assert the new file exists
assert_file_exists "$MOCK_WEBAPP_SCRATCH/src/errors.rs"

# Assert it contains the enum
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/errors.rs" "AppError"
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/errors.rs" "NotFound"

# Assert lib.rs was updated
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/lib.rs" "errors"

# Verify the project still compiles
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
assert_success $?

cleanup_mock_webapp
report_result
