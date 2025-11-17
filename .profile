sources=()
paths=(
    "$HOME/.local/bin"
    "$HOME/.go/bin"
    "/opt/go/bin"
)

if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

for path in "${sources[@]}"; do
    if [ -f "${path}" ]; then
        source "${path}"
    fi
done

for path in "${paths[@]}"; do
    if [ -d "${path}" ] && [[ $PATH != *"${path}"* ]]; then
        PATH="$PATH:${path}"
    fi
done
