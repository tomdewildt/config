#!/bin/bash
set -euo pipefail

# Usage
usage() {
    echo "Usage: $0 <number> [--logs <job-id>] [--before N] [--limit N]"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                           # Fetch pipeline status for the current branch PR/MR"
    echo "  $(basename "$0") 42                        # Fetch pipeline status for PR/MR #42"
    echo "  $(basename "$0") --logs 12345              # Fetch the last 200 lines of logs for pipeline job 12345"
    echo "  $(basename "$0") --logs 12345 --before 114 # Fetch 200 lines before offset 114 for pipeline job 12345"
    echo ""
    echo "Options:"
    echo "  --logs <job-id>   Fetch logs for a specific pipeline job"
    echo "  --before N        Show --limit lines ending before line N"
    echo "  --limit N         Number of lines to show (default: 200)"
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
    exec "$SCRIPT_DIR/fetch-github-pipeline.sh" "$@"
elif [[ "$REMOTE" == *"gitlab.com"* ]] || [[ "$REMOTE" =~ gitlab\. ]]; then
    exec "$SCRIPT_DIR/fetch-gitlab-pipeline.sh" "$@"
else
    echo "Error: could not determine repository type from remote: $REMOTE" >&2
    echo "Supported hosts: github.com, gitlab.com" >&2
    exit 1
fi
