#! /bin/bash
function cl() {
    DIR="$*";
        if [ $# -lt 1 ]; then
                DIR=$HOME;
    fi;
    builtin cd "${DIR}" && ls --color=auto --group-directories-first --classify
}
