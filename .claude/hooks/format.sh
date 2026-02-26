#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
EXT="${FILE_PATH##*.}"

# Run format
case "$EXT" in
    css|html|js|json|jsx|ts|tsx)
        npx -y prettier --write "$FILE_PATH" ;;
    go)
        go fmt "$FILE_PATH" ;;
    py)
        ruff format "$FILE_PATH" ;;
    tf|tfvars)
        terraform fmt "$FILE_PATH" ;;
esac &> /dev/null || true
