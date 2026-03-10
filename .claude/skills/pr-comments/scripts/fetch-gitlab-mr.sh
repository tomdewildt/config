#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Usage
usage() {
    echo "Usage: "$0" <number>"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")        # Fetch MR for the current branch"
    echo "  $(basename "$0") 42     # Fetch MR !42"
    exit 1
}
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
fi

# Validate
if [ $# -gt 1 ] || { [ $# -eq 1 ] && ! [[ "$1" =~ ^[0-9]+$ ]]; }; then
    usage
fi

# Check if a MR number is provided or use default
if [ $# -eq 1 ]; then
    NUMBER="$1"
else
    NUMBER=$(glab mr view --output json | jq '.iid')
fi

# Fetch project path and encode it for API calls
REPO=$(git remote get-url origin | sed -E 's|.*gitlab\.com[:/]||' | sed 's|\.git$||')
REPO_ENCODED=$(printf '%s' "$REPO" | jq -Rr @uri)

# Fetch MR content
MR=$(glab api "projects/$REPO_ENCODED/merge_requests/$NUMBER" | jq '{
    number: .iid,
    title: .title,
    body: .description,
    url: .web_url
}')

# Fetch notes (general, non-system comments)
NOTES=$(glab api "projects/$REPO_ENCODED/merge_requests/$NUMBER/notes" --paginate | jq '[
    .[] | select(.system == false and .position == null) | {author: .author.username, body: .body}
]')

# Fetch inline discussions
DISCUSSIONS=$(glab api "projects/$REPO_ENCODED/merge_requests/$NUMBER/discussions" --paginate)

# Build reviews from inline discussions (each discussion thread = one review comment + replies)
REVIEWS=$(echo "$DISCUSSIONS" | jq '[
    .[] |
    select(.notes[0].position != null) |
    {
        author: .notes[0].author.username,
        state: "COMMENTED",
        body: "",
        comments: [
            {
                author: .notes[0].author.username,
                file: (.notes[0].position.new_path // .notes[0].position.old_path // ""),
                line: (.notes[0].position.new_line // .notes[0].position.old_line // null),
                diff: "",
                body: .notes[0].body,
                replies: [.notes[1:] | .[] | {author: .author.username, body: .body}]
            }
        ]
    }
]')

# Combine MR content, notes, and reviews
jq -n --argjson pr "$MR" --argjson notes "$NOTES" --argjson reviews "$REVIEWS" '$pr + {
    comments: $notes,
    reviews: $reviews
}'
