#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
EXT="${FILE_PATH##*.}"

# Change directory
cd "$(dirname "$FILE_PATH")"

# Run format
case "$EXT" in
    css|html|js|json|jsx|ts|tsx)
        CONTEXT=$(npx -y prettier --write "$FILE_PATH" 2>&1) ;;
    go)
        CONTEXT=$(go fmt "$FILE_PATH" 2>&1) ;;
    py)
        CONTEXT=$(ruff format "$FILE_PATH" 2>&1) ;;
    tf|tfvars)
        CONTEXT=$(terraform fmt "$FILE_PATH" 2>&1) ;;
esac || true

# Output context
if [[ -n "${CONTEXT:-}" ]]; then
    jq -n --arg context "$CONTEXT" '{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": $context}}'
fi
