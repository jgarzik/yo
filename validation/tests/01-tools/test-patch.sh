#!/bin/bash
# Test: Patch tool can apply unified diffs
# Expected: File contains patched content

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

setup_test "patch-basic"
reset_scratch

# Create initial file
cat > "$SCRATCH_DIR/example.txt" << 'EOF'
line 1
line 2
line 3
line 4
EOF

# Create patch file
cat > "$SCRATCH_DIR/changes.patch" << 'EOF'
--- a/example.txt
+++ b/example.txt
@@ -1,4 +1,5 @@
 line 1
+inserted line
 line 2
 line 3
 line 4
EOF

PROMPT="Apply the patch from fixtures/scratch/changes.patch to fixtures/scratch/example.txt using the Patch tool"

OUTPUT=$(run_yo_oneshot "$PROMPT" --mode acceptEdits)
EXIT_CODE=$?

assert_exit_code 0 "$EXIT_CODE"
assert_file_contains "$SCRATCH_DIR/example.txt" "inserted line"
assert_tool_called "Patch" "$OUTPUT"

report_result
