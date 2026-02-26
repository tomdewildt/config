#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Run lint
if [[ "$FILE_PATH" == *.go ]]; then
    CONTEXT=$(go vet "$FILE_PATH" 2>&1) || true
elif [[ "$FILE_PATH" == *.js || "$FILE_PATH" == *.jsx || "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx ]]; then
    CONTEXT=$(npx -y eslint --fix "$FILE_PATH" 2>&1) || true
elif [[ "$FILE_PATH" == *.py ]]; then
    CONTEXT=$(ruff check --fix "$FILE_PATH" 2>&1) || true
elif [[ "$FILE_PATH" == *.tf || "$FILE_PATH" == *.tfvars ]]; then
    CONTEXT=$(tflint "$FILE_PATH" 2>&1) || true
fi

# Output context
if [[ -n "${CONTEXT:-}" ]]; then
    jq -n --arg context "$CONTEXT" '{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": $context}}'
fi
