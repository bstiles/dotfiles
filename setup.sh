#!/bin/bash
shopt -s extglob
set -o errexit
set -o nounset
unset CDPATH

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
cat <<EOF
usage: $(basename "$0")

Sets up Bash and tmux initialization files on a new machine.
EOF
}

function abort_and_display_help {
    display_help && echo
    echo "-- ABORTED:"
    abort "$@"
}

[[ ${1-} = @(--help|-h) ]] && display_help && exit 0

echo "Linking/writing initialization files to $HOME..."

files=(bash_alias bashrc bash_profile inputrc profile tmux.conf)
if [ "$(uname -s)" = "Darwin" ]; then
    files=(${files[@]} tmux-osx.conf)
fi


if [ "$(uname -s)" = "Darwin" ]; then
    export READLINK=readlink
else
    export READLINK='readlink -f'
fi

config_dir=${here#$HOME/}

for x in ${files[@]}; do
    if [ -L "$HOME/.$x" -a "$($READLINK "$HOME/.$x")" = "$config_dir/$x" ]; then
        continue
    fi
    if [ -L "$HOME/.$x" -o -f "$HOME/.$x" ]; then
        mv "$HOME/.$x" "$HOME/.$x-$(date "+%Y-%m-%d-%H-%M-%S")"
    fi
    if [ -e "$HOME/.$x" ]; then
        abort "$HOME/.$x exists and isn't a file."
    fi
    ln -s "$config_dir/$x" "$HOME/.$x"
done

