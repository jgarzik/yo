#!/bin/bash
# Test: Ask yo to list available MCP tools
# Expected: yo lists the calculator tools

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "mcp-tool-list"

# Check if mcp-calc binary exists
MCP_CALC="${FIXTURES_DIR}/mcp_calc_server/target/release/mcp-calc"
if [ ! -x "$MCP_CALC" ]; then
    echo "  SKIP: mcp-calc not built (run: cargo build --release -p mcp-calc)" >> "$TEST_LOG"
    echo -e "${YELLOW}SKIP${NC}: mcp-tool-list (binary not built)"
    exit 0
fi

# Create a temporary config with MCP server (TOML format)
TMP_BASE=$(mktemp)
TMP_CONFIG="${TMP_BASE}.toml"
mv "$TMP_BASE" "$TMP_CONFIG"

# Get API key from environment
API_KEY="${VENICE_API_KEY:-${ANTHROPIC_API_KEY:-${OPENAI_API_KEY:-}}}"
if [ -z "$API_KEY" ]; then
    echo "  SKIP: No API key found" >> "$TEST_LOG"
    rm -f "$TMP_CONFIG"
    echo -e "${YELLOW}SKIP${NC}: mcp-tool-list (no API key)"
    exit 0
fi

cat > "$TMP_CONFIG" << EOF
default_target = "qwen3-235b-a22b-instruct-2507@venice"

[backends.venice]
base_url = "https://api.venice.ai/api/v1"
api_key = "$API_KEY"

[mcp.servers.calc]
command = "$MCP_CALC"
args = []
EOF

# Ask yo what tools are available
OUTPUT=$("$YO_BIN" -p "What MCP tools are available? List them." --yes --config "$TMP_CONFIG" 2>&1)
EXIT_CODE=$?

rm -f "$TMP_CONFIG"

echo "Command output:" >> "$TEST_LOG"
echo "$OUTPUT" >> "$TEST_LOG"
echo "Exit code: $EXIT_CODE" >> "$TEST_LOG"

# Assert the calculator tools are mentioned
assert_output_contains_any "$OUTPUT" "calc" "add" "multiply" "calculator"

report_result
