# -*- mode: sh -*-
##
## This is executed for each login shell (sourced by .bash_profile
## when bash is used).
##

[[ -f $HOME/.profile_local ]] && source "$HOME/.profile_local"

######################################################################
## Paths
##

abs_real_path() {
    local bn=$(basename -- "${1:?abs_real_path called without argument}")
    local dn=$(dirname -- "$1")
    declare -il depth=0
    while [[ -L "$dn/$bn" ]]; do
        (( depth++ < 10 )) || {
            echo CYCLICAL LINK: "$dn/$bn" 1>&2
            printf %s $'\0'
            return 1
        }
        local l=$(readlink -- "$dn/$bn")
        bn=$(basename -- "$l")
        if [[ $l =~ ^/ ]]; then
            dn=$(dirname -- "$l")
        else
            dn=$dn/$(dirname -- "$l")
        fi
    done
    abs_dn=$(cd -- "$dn" && pwd -P)
    [[ $abs_dn ]] || {
        printf %s $'\0'
        return 64
    }
    printf %s/%s "$abs_dn" "$bn"
}

real_base_name() {
    basename -- "$(abs_real_path "${1:?real_base_name called without argument}")"
}

abs_path() {
    local f=${1:?abs_path called without argument}
    printf %s/%s "$(cd "$(dirname -- "$f")" && pwd)" "$(basename -- "$f")"
}

######################################################################
## Path
##

# 2014-06-10 bstiles: Add VMWare Fusion command line tools.
# 2014-12-12 bstiles: Add Homebrew path.
if [[ $(uname -s) = Darwin ]]; then
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
export PGCLIENTENCODING=UTF8

if [[ ${TMPDIR-} && $(readlink "$HOME/tmpdir") != $(dirname -- "$TMPDIR")/$(basename -- "$TMPDIR") ]]; then
    ln -sfn "$(dirname $TMPDIR)/$(basename $TMPDIR)" "$HOME/tmpdir"
fi

export JAVA_VERSION=1.8
export JAVA_HOME=$(/usr/libexec/java_home -version $JAVA_VERSION)
export VAGRANT_VMWARE_CLONE_DIRECTORY=~/Vagrant
export MACHINE_STORAGE_PATH=~/Machine
export MY_DOTFILES_DIR=$(dirname -- "$(abs_real_path "${BASH_SOURCE[0]}")")
