sources=()
paths=(
    "$HOME/.local/bin"
    "$HOME/.go/bin"
    "/opt/homebrew/opt/node@22/bin"
    "/opt/homebrew/opt/postgresql@15/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
)

for file in "${sources[@]}"; do
    if [ -f "${file}" ]; then
        source "${file}"
    fi
done

for dir in "${paths[@]}"; do
    if [ -d "${dir}" ] && [[ $PATH != *"${dir}"* ]]; then
        PATH="${dir}:$PATH"
    fi
done
