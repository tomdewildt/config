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
complete -C "/opt/homebrew/bin/aws_completer" aws

# Environment
export CLICOLOR=1
export CLICOLOR_FORCE=1
export EDITOR=nano
export GOPATH=$HOME/.go
