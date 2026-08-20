case $- in
    *i*) ;;
    *) return;;
esac

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth

shopt -s histappend
shopt -s checkwinsize

# Setup
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Colors
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [[ "$color_prompt" == yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    use_color=true
else
    use_color=false
fi

# Aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases $use_color
fi

# Functions
if [ -f ~/.bash_functions ]; then
    source ~/.bash_functions $use_color
fi

# Completions
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

command -v aws_completer > /dev/null && complete -C aws_completer aws
command -v bun > /dev/null && source <(SHELL=bash bun completions)
command -v codex > /dev/null && source <(codex completion bash 2>/dev/null)
command -v dive > /dev/null && source <(dive completion bash 2>/dev/null)
command -v fzf > /dev/null && eval "$(fzf --bash)"
command -v gh > /dev/null && source <(gh completion -s bash 2>/dev/null)
command -v glab > /dev/null && source <(glab completion -s bash 2>/dev/null)
command -v mise > /dev/null && source <(mise completion bash 2>/dev/null)
command -v ngrok > /dev/null && source <(ngrok completion 2>/dev/null)
command -v npm > /dev/null && source <(npm completion 2>/dev/null)
command -v packer > /dev/null && complete -o nospace -C "$(command -v packer)" packer
command -v rustup > /dev/null && source <(rustup completions bash)
command -v terraform > /dev/null && complete -o nospace -C "$(command -v terraform)" terraform
command -v uv > /dev/null && source <(uv generate-shell-completion bash)

[ -f /usr/lib/google-cloud-sdk/completion.bash.inc ] && source /usr/lib/google-cloud-sdk/completion.bash.inc
[ -f "$HOME/google-cloud-sdk/completion.bash.inc" ] && source "$HOME/google-cloud-sdk/completion.bash.inc"

# Environment
export DO_NOT_TRACK=true
export EDITOR=nano
export GH_TELEMETRY=false
export GOPATH=$HOME/.go
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Tooling
command -v mise > /dev/null && eval "$(mise activate bash)"
