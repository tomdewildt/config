#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
EXT="${FILE_PATH##*.}"

# Run lint
case "$EXT" in
    go)
        CONTEXT=$(go vet "$FILE_PATH" 2>&1) ;;
    js|jsx|ts|tsx)
        CONTEXT=$(npx -y eslint --fix "$FILE_PATH" 2>&1) ;;
    py)
        CONTEXT=$(ruff check --fix "$FILE_PATH" 2>&1) ;;
    tf|tfvars)
        CONTEXT=$(tflint "$FILE_PATH" 2>&1) ;;
esac || true

# Output context
if [[ -n "${CONTEXT:-}" ]]; then
    jq -n --arg context "$CONTEXT" '{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": $context}}'
fi
