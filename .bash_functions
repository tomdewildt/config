#! /bin/bash
claude-cloud() {
    printf '\033]0;claude (cloud)\007'
    claude "$@"
}

claude-local() {
    if ! lms ps --json 2>/dev/null | grep -q '"modelKey":"qwen/qwen3.6-35b-a3b"'; then
        echo "Loading qwen/qwen3.6-35b-a3b..."
        lms load qwen/qwen3.6-35b-a3b -c 262144 -y
    fi

    printf '\033]0;claude (local)\007'

    export ANTHROPIC_BASE_URL=http://localhost:1234
    export ANTHROPIC_AUTH_TOKEN=lmstudio
    export CLAUDE_CODE_MAX_CONTEXT_TOKENS=262144
    claude --model qwen/qwen3.6-35b-a3b "$@"
}
