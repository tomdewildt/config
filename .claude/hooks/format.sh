#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Run format
if [[ "$FILE_PATH" == *.go ]]; then
    go fmt "$FILE_PATH" &> /dev/null || true
elif [[ "$FILE_PATH" == *.css || "$FILE_PATH" == *.html || "$FILE_PATH" == *.js || "$FILE_PATH" == *.json || "$FILE_PATH" == *.jsx || "$FILE_PATH" == *.ts  || "$FILE_PATH" == *.tsx ]]; then
    npx -y prettier --write "$FILE_PATH" &> /dev/null || true
elif [[ "$FILE_PATH" == *.py ]]; then
    ruff format "$FILE_PATH" &> /dev/null || true
elif [[ "$FILE_PATH" == *.tf || "$FILE_PATH" == *.tfvars ]]; then
    terraform fmt "$FILE_PATH" &> /dev/null || true
fi
