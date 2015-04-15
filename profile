# -*- mode: sh -*-
##
## This is executed for each login shell (sourced by .bash_profile
## when bash is used).
##

[ -f "$HOME/.profile_local" ] && source "$HOME/.profile_local"

######################################################################
## Cross platform support
##

if [ "$(uname -s)" = "Darwin" ]; then
    export READLINK=readlink
    export STAT='stat -f %Um'
else
    export READLINK='readlink -f'
    export STAT='stat -c %Y'
fi

######################################################################
## Paths
##

function abs_real_path {
    local f="${1:?abs_real_path called without argument}"
    f="$(cd "$(dirname -- "$f")" && pwd)/$(basename -- "$f")"
    if [ -L "$f" ]; then
        (
            allowed_depth=10
            x=$f
            while [ -L "$x" ]; do
                [[ $allowed_depth = 0 ]] \
                    && abort $ERR_MAX_LINK_DEPTH_EXCEEDED
                cd "$(dirname -- "$x")"
                cd "$(dirname -- "$($READLINK "$x")")"
                x="$(pwd)/$(basename -- "$($READLINK "$x")")"
                allowed_depth=$(($allowed_depth-1))
            done
            printf %s "$(cd "$(dirname -- "$x")" && pwd)/$(basename -- "$x")"
        )
    else
        printf %s "$(cd "$(dirname -- "$1")" && pwd)/$(basename -- "$1")"
    fi
}

######################################################################
## Path
##

# 2014-06-10 bstiles: Add VMWare Fusion command line tools.
# 2014-12-12 bstiles: Add Homebrew path.
if [ "$(uname -s)" = "Darwin" ]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    export PATH="$PATH:/Applications/VMware Fusion.app/Contents/Library"
fi

# 2014-06-25 bstiles: path to selectively override existing items on the path.
# This must be executed last so that overrides is at the head of the path.
export PATH="$HOME/bin/overrides:$HOME/bin/on-the-path:$PATH"

######################################################################
## Environment
##

# 2013-07-23 bstiles: Force UTF8. psql under emacs behaves badly otherwise.
PGCLIENTENCODING=UTF8

if [ -n "$TMPDIR" -a "$($READLINK $HOME/tmpdir)" != "$(dirname $TMPDIR)/$(basename $TMPDIR)" ]; then
    ln -sfn "$(dirname $TMPDIR)/$(basename $TMPDIR)" "$HOME/tmpdir"
fi

export JAVA_VERSION=1.8
export JAVA_HOME=$(/usr/libexec/java_home -version $JAVA_VERSION)
export VAGRANT_VMWARE_CLONE_DIRECTORY=~/Vagrant
export MACHINE_STORAGE_PATH=~/Machine
export MY_DOTFILES_DIR=$(dirname "$(abs_real_path "$BASH_SOURCE")")
