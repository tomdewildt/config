#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Usage
usage() {
    echo "Usage: $0 <number> [--logs <job-id>] [--before N] [--limit N]"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                           # Fetch pipeline status for the current branch PR"
    echo "  $(basename "$0") 42                        # Fetch pipeline status for PR #42"
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

# Parse arguments
NUMBER=""
JOB=""
BEFORE=""
LIMIT=200

while [[ $# -gt 0 ]]; do
    case "$1" in
        --logs)
            JOB="$2"
            shift 2
            ;;
        --before)
            BEFORE="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ "$1" =~ ^[0-9]+$ ]] && [ -z "$NUMBER" ]; then
                NUMBER="$1"
                shift
            else
                usage
            fi
            ;;
    esac
done

# Fetch repo name
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

# Fetch pipeline logs
if [ -n "$JOB" ]; then
    RAW_LOG=$(gh api "repos/$REPO/actions/jobs/$JOB/logs" 2>/dev/null || true)
    if [ -z "$RAW_LOG" ]; then
        echo "Error: could not fetch logs for job $JOB" >&2
        exit 1
    fi

    # Clean pipeline log
    # * Strip ANSI escape codes
    # * Strip GitHub Actions timestamp prefixes (e.g. "2026-03-26T12:20:35.1234567Z ")
    # * Remove blank lines left over from stripping
    CLEAN_LOG=$(echo "$RAW_LOG" \
        | sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' \
        | sed $'s/\x1b\[K//g' \
        | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:.]+Z //' \
        | sed '/^[[:space:]]*$/d' \
    )

    TOTAL_LINES=$(echo "$CLEAN_LOG" | wc -l | tr -d ' ')

    # Select lines
    if [ -n "$BEFORE" ]; then
        END="$BEFORE"
    else
        END="$TOTAL_LINES"
    fi
    OFFSET=$(( END - LIMIT > 0 ? END - LIMIT : 0 ))
    LINES=$(echo "$CLEAN_LOG" | tail -n +"$((OFFSET + 1))" | head -n "$((END - OFFSET))")

    # Combine job, total, offset, limit, and lines
    echo "$LINES" | jq -R -s --arg job_id "$JOB" \
        --argjson total_lines "$TOTAL_LINES" \
        --argjson before "$OFFSET" \
        --argjson limit "$LIMIT" \
        '{job_id: $job_id, total_lines: $total_lines, before: $before, limit: $limit, lines: (split("\n") | if .[-1] == "" then .[:-1] else . end)}'
    exit 0
fi

# Fetch pipeline overview
if [ -z "$NUMBER" ]; then
    NUMBER=$(gh pr view --json number --jq '.number')
fi

# Fetch pr content
PR=$(gh pr view "$NUMBER" --json number,title,url,headRefOid)
COMMIT=$(echo "$PR" | jq -r '.headRefOid')

# Fetch workflow runs
RAW_RUNS=$(gh api "repos/$REPO/actions/runs?head_sha=$COMMIT&per_page=100" --jq '[.workflow_runs[] | {id: .id, name: .name, status: .status, conclusion: .conclusion, url: .html_url}]' 2>/dev/null || echo "[]")

# Format workflow
TOTAL_RUNS=$(echo "$RAW_RUNS" | jq 'length')
if [ "$TOTAL_RUNS" -eq 0 ]; then
    FORMATTED_RUNS="[]"
else
    FORMATTED_RUNS=$(echo "$RAW_RUNS" | jq -c '.[]' | while IFS= read -r run; do
        RUN_ID=$(echo "$run" | jq -r '.id')
        JOBS=$(gh api "repos/$REPO/actions/runs/$RUN_ID/jobs?per_page=100" --jq '[.jobs[] | {id: .id, name: .name, status: .status, conclusion: .conclusion, started_at: .started_at, completed_at: .completed_at}]' 2>/dev/null || echo "[]")
        echo "$run" | jq --argjson jobs "$JOBS" '. + {jobs: $jobs}'
    done | jq -s '.')
fi

# Combine PR info and runs
jq -n --argjson pr "$PR" --argjson runs "$FORMATTED_RUNS" '{
    number: $pr.number,
    title: $pr.title,
    url: $pr.url,
    runs: $runs
}'
