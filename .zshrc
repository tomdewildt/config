# Aliases
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases $use_color
fi

# Functions
if [ -f ~/.zsh_functions ]; then
    source ~/.zsh_functions $use_color
fi

# Completions
FPATH=/opt/homebrew/share/zsh-completions:$FPATH
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
chmod go-w /opt/homebrew/share
chmod -R go-w /opt/homebrew/share/zsh

command -v aws_completer > /dev/null && complete -C aws_completer aws
command -v bun > /dev/null && source <(SHELL=zsh bun completions)
command -v codex > /dev/null && source <(codex completion zsh 2>/dev/null)
command -v dive > /dev/null && source <(dive completion zsh 2>/dev/null)
command -v fzf > /dev/null && source <(fzf --zsh)
command -v gh > /dev/null && source <(gh completion -s zsh 2>/dev/null)
command -v glab > /dev/null && source <(glab completion -s zsh 2>/dev/null)
command -v mise > /dev/null && source <(mise completion zsh 2>/dev/null)
command -v npm > /dev/null && source <(npm completion 2>/dev/null)
command -v packer > /dev/null && complete -o nospace -C "$(command -v packer)" packer
command -v rustup > /dev/null && source <(rustup completions zsh)
command -v terraform > /dev/null && complete -o nospace -C "$(command -v terraform)" terraform
command -v uv > /dev/null && source <(uv generate-shell-completion zsh)

[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ] && source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

# Environment
export CLICOLOR=1
export CLICOLOR_FORCE=1
export DO_NOT_TRACK=true
export EDITOR=nano
export GH_TELEMETRY=false
export GOPATH=$HOME/.go
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Tooling
command -v mise > /dev/null && eval "$(mise activate zsh)"
