#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Awaiting your input"')

# Show notification
if command -v alerter >/dev/null 2>&1; then
    alerter --title "$TITLE" --message "$MESSAGE" --app-icon 'https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/png/claude-ai.png' --sound default > /dev/null 2>&1
elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$TITLE" "$MESSAGE"
fi
