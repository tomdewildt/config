#!/bin/bash
set -euo pipefail

# Usage
usage() {
    echo "Usage: $0 <number>"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")        # Fetch PR/MR for the current branch"
    echo "  $(basename "$0") 42     # Fetch PR/MR #42"
    exit 1
}
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
fi

# Detect scripts dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect remote type
REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

if [[ "$REMOTE" == *"github.com"* ]]; then
    exec "$SCRIPT_DIR/fetch-github-pr.sh" "$@"
elif [[ "$REMOTE" == *"gitlab.com"* ]] || [[ "$REMOTE" =~ gitlab\. ]]; then
    exec "$SCRIPT_DIR/fetch-gitlab-mr.sh" "$@"
else
    echo "Error: could not determine repository type from remote: $REMOTE" >&2
    echo "Supported hosts: github.com, gitlab.com" >&2
    exit 1
fi
