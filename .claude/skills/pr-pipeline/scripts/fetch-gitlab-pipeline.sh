#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Usage
usage() {
    echo "Usage: $0 [number] [--logs <job-id>] [--before N] [--limit N]"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                           # Fetch pipeline status for the current branch MR"
    echo "  $(basename "$0") 42                        # Fetch pipeline status for MR #42"
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

# Fetch project path and encode it for API calls
REPO=$(git remote get-url origin | sed -E 's|.*gitlab\.com[:/]||' | sed 's|\.git$||')
REPO_ENCODED=$(printf '%s' "$REPO" | jq -Rr @uri)

# Fetch pipeline logs
if [ -n "$JOB" ]; then
    RAW_LOG=$(glab api "projects/$REPO_ENCODED/jobs/$JOB/trace" 2>/dev/null || true)
    if [ -z "$RAW_LOG" ]; then
        echo "Error: could not fetch logs for job $JOB" >&2
        exit 1
    fi

    # Clean pipeline log
    # * Strip ANSI escape codes
    # * Remove GitLab section markers (section_start/section_end lines)
    # * Strip GitLab timestamp prefixes (e.g. "2026-03-26T12:20:35.740774Z 01O ")
    # * Remove blank lines left over from stripping
    CLEAN_LOG=$(echo "$RAW_LOG" \
        | sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' \
        | sed $'s/\x1b\[K//g' \
        | grep -v '^section_start:' \
        | grep -v '^section_end:' \
        | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:.]+Z [0-9A-Za-z]+ ?//' \
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
    NUMBER=$(glab mr view --output json | jq '.iid')
fi

# Fetch mr content
MR=$(glab api "projects/$REPO_ENCODED/merge_requests/$NUMBER" | jq '{
    number: .iid,
    title: .title,
    url: .web_url
}')

# Fetch pipelines
PIPELINES=$(glab api "projects/$REPO_ENCODED/merge_requests/$NUMBER/pipelines" | jq '[.[] | {id: .id, status: .status, ref: .ref, sha: .sha, web_url: .web_url}]')
PIPELINE=$(echo "$PIPELINES" | jq '.[0]')
if [ "$(echo "$PIPELINE" | jq 'type')" = "\"null\"" ]; then
    jq -n --argjson mr "$MR" '{
        number: $mr.number,
        title: $mr.title,
        url: $mr.url,
        pipeline: null
    }'
    exit 0
fi
PIPELINE_ID=$(echo "$PIPELINE" | jq -r '.id')

# Fetch pipeline jobs
JOBS=$(glab api "projects/$REPO_ENCODED/pipelines/$PIPELINE_ID/jobs" --paginate | jq '[.[] | {id: .id, name: .name, stage: .stage, status: .status, duration: .duration, web_url: .web_url}]')

# Combine MR info, pipeline, and jobs
jq -n --argjson mr "$MR" --argjson pipeline "$PIPELINE" --argjson jobs "$JOBS" '{
    number: $mr.number,
    title: $mr.title,
    url: $mr.url,
    pipeline: ($pipeline + {jobs: $jobs})
}'
