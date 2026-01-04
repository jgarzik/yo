#!/bin/bash
# Test: Ask yo to add API documentation to README
# Expected: yo adds an API section to README.md

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "update-readme"

# Reset mock_webapp scratch
reset_mock_webapp

# Verify README.md doesn't have an API section initially
if grep -qi "## API" "$MOCK_WEBAPP_SCRATCH/README.md"; then
    echo "  SKIP: README already has API section" >> "$TEST_LOG"
    cleanup_mock_webapp
    echo -e "${YELLOW}SKIP${NC}: update-readme (already has API section)"
    exit 0
fi

# Ask yo to update the README
OUTPUT=$(run_yo_in_mock_webapp "The README.md is missing API documentation. Add a section documenting the available API endpoints/handlers based on what's in src/api/handlers.rs.")

# Assert README was modified
assert_git_dirty "$MOCK_WEBAPP_SCRATCH"

# Assert README now has API documentation
assert_file_contains "$MOCK_WEBAPP_SCRATCH/README.md" "API"

cleanup_mock_webapp
report_result
