#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Select fields
INPUT=$(cat)
SESSION=$(echo "$INPUT" | jq -r '.session_id // empty')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Awaiting your input"')

# Show notification
if command -v alerter >/dev/null 2>&1; then
    alerter --title "$TITLE" --message "$MESSAGE" --app-icon 'https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/png/claude-ai.png' --sound default ${SESSION:+--group "$SESSION"} > /dev/null 2>&1
elif command -v notify-send >/dev/null 2>&1; then
    # Hash the session string and cap it to the 32-bit signed int max so it's a valid replace-id.
    NOTIFY_ID=$(echo "$SESSION" | cksum | awk '{print $1 % 2147483647}')
    notify-send "$TITLE" "$MESSAGE" ${SESSION:+-r "$NOTIFY_ID"}
fi
