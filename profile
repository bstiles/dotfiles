# -*- mode: sh -*-
##
## This is executed for each login shell (sourced by .bash_profile
## when bash is used).
##

[[ -f $HOME/.profile_local ]] && source "$HOME/.profile_local"

if [[ ${LC_TERMINAL-} == iTerm2 ]]; then
    export TERM=screen-256color
fi

# 2020-02-06 bstiles: Initialize lmod (http://lmod.readthedocs.org/)
if [[ -d /usr/local/opt/lmod/init/profile ]]; then
    source /usr/local/opt/lmod/init/profile
    export LMOD_COLORIZE=YES
fi

######################################################################
## Paths
##

abs_real_path() {
    local bn=$(basename -- "${1:?abs_real_path called without argument}")
    local dn=$(dirname -- "$1")
    local depth=0
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

# 2019-03-22 bstiles: Start with base path.
if [[ -f /etc/paths && -r /etc/paths ]]; then
    PATH=$(echo $(cat /etc/paths) | tr ' ' :)
elif [[ -f /etc/environment && -r /etc/environment ]]; then
    PATH=$(eval $(cat /etc/environment); echo "$PATH")
else
    echo PATH=/usr/bin:/usr/sbin:/bin:/sbin
fi

# 2014-06-10 bstiles: Add VMWare Fusion command line tools.
# 2014-12-12 bstiles: Add Homebrew path.
if [[ $(uname -s) = Darwin ]]; then
    PATH=/usr/local/bin:/usr/local/sbin:$PATH
    PATH=$PATH:"/Applications/VMware Fusion.app/Contents/Library"
fi
# 2015-05-19 bstiles: OCaml support
if [[ -d $HOME/.opam/system/bin ]]; then
    # OPAM configuration
    . /Users/bstiles/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
    eval $(opam config env)
fi

# 2019-06-25 bstiles: Rust
PATH=$HOME/.cargo/bin:$PATH

# 2019-12-29 bstiles: GNU ARM EMbedded
PATH=$PATH:$HOME/Development/Toolchains/gcc-arm-none-eabi/bin

# 2018-08-08 bstiles: BacicTeX
if [[ -d /usr/local/texlive/2018/bin/x86_64-darwin ]]; then
    PATH=/usr/local/texlive/2018/bin/x86_64-darwin:$PATH
fi

if [[ -x /usr/libexec/path_helper ]]; then
    eval `/usr/libexec/path_helper -s`
fi

# 2019-07-13 bstiles: GNU make
if [[ -x /usr/local/opt/make/libexec/gnubin ]]; then
    PATH=/usr/local/opt/make/libexec/gnubin:$PATH
fi

if [[ -d /snap/bin ]]; then
    PATH=/snap/bin:$PATH
fi

# 2020-03-07 bstiles: LinuxBrew
if [[ $(uname -s) == Linux && -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH

# 2014-06-25 bstiles: path to selectively override existing items on the path.
# This must be executed last so that overrides is at the head of the path.
PATH=$HOME/bin/overrides:$HOME/bin/on-the-path:$PATH

######################################################################
## Environment
##

# 2013-07-23 bstiles: Force UTF8. psql under emacs behaves badly otherwise.
export PGCLIENTENCODING=UTF8

if [[ ${TMPDIR-} && $(readlink "$HOME/tmpdir") != $(dirname -- "$TMPDIR")/$(basename -- "$TMPDIR") ]]; then
    ln -sfn "$(dirname $TMPDIR)/$(basename $TMPDIR)" "$HOME/tmpdir"
fi

if [[ -x /usr/libexec/java_home ]]; then
    export JAVA_VERSION=11
    # export JAVA_HOME=$(/usr/libexec/java_home -version $JAVA_VERSION)
    export JAVA_HOME=$(ls -1d "/Users/$USER/Library/Application Support/JetBrains/Toolbox/apps/IDEA-U/"*/*"/IntelliJ IDEA.app/Contents/jbr/Contents/Home" | tail -1)
fi
export MACHINE_STORAGE_PATH=~/Machine
export MY_DOTFILES_DIR=$(dirname -- "$(abs_real_path "${BASH_SOURCE[0]}")")
