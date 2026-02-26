#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

MAX_LINES=500

# Select fields
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Check file exists
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Check line count
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
if [[ "$LINE_COUNT" -le "$MAX_LINES" ]]; then
    exit 0
fi

# Output context
CONTEXT="Warning: $FILE_PATH has $LINE_COUNT lines (limit: $MAX_LINES). Consider splitting this file into smaller modules."
jq -n --arg context "$CONTEXT" '{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": $context}}'
