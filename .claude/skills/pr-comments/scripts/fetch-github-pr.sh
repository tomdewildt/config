#!/bin/bash
set -euo pipefail
export CLICOLOR=0
export CLICOLOR_FORCE=0

# Usage
usage() {
    echo "Usage: "$0" <number>"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")        # Fetch PR for the current branch"
    echo "  $(basename "$0") 42     # Fetch PR #42"
    exit 1
}
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
fi

# Validate
if [ $# -gt 1 ] || { [ $# -eq 1 ] && ! [[ "$1" =~ ^[0-9]+$ ]]; }; then
    usage
fi

# Check if a pr number is provided or use default
if [ $# -eq 1 ]; then
    NUMBER="$1"
else
    NUMBER=$(gh pr view --json number --jq '.number')
fi

# Fetch repo name
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

# Fetch pr content
PR=$(gh pr view "$NUMBER" --json number,title,body,url,comments --jq '{
    number: .number,
    title: .title,
    body: .body,
    url: .url,
    comments: [.comments[] | select(.authorAssociation != "NONE") | {author: .author.login, body: .body}]
}')

# Fetch reviews
REVIEWS=$(gh api "repos/$REPO/pulls/$NUMBER/reviews" --paginate --jq '[.[] | {
    id: .id,
    author: .user.login,
    state: .state,
    body: .body
}]')

# Fetch comments
COMMENTS=$(gh api "repos/$REPO/pulls/$NUMBER/comments" --paginate --jq '[.[] | {
    id: .id,
    in_reply_to_id: .in_reply_to_id,
    review_id: .pull_request_review_id,
    author: .user.login,
    file: .path,
    line: .line,
    diff: .diff_hunk,
    body: .body
}]')

# Combine pr content, reviews, and comments
jq -n --argjson pr "$PR" --argjson reviews "$REVIEWS" --argjson comments "$COMMENTS" '$pr + {
    reviews: [
        $reviews[] | . as $review | {
            author: .author,
            state: .state,
            body: .body,
            comments: [
                $comments[] | select(.review_id == $review.id and .in_reply_to_id == null) | . as $comment | {
                    author: .author,
                    file: .file,
                    line: .line,
                    diff: .diff,
                    body: .body,
                    replies: [$comments[] | select(.in_reply_to_id == $comment.id) | {author: .author, body: .body}]
                }
            ]
        } | select(.body != "" and (.comments | length) > 0)
    ]
}'
