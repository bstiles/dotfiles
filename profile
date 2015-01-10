# -*- mode: sh -*-
##
## This is executed for each login shell (sourced by .bash_profile
## when bash is used).
##

[ -f "$HOME/.profile_local" ] && source "$HOME/.profile_local"

# 2012-12-18 bstiles: Haskell goodies
export PATH="$HOME/.cabal/bin:$PATH"

# 2014-06-10 bstiles: Add VMWare Fusion command line tools.
# 2014-12-12 bstiles: Add Homebrew path.
if [ "$(uname -s)" = "Darwin" ]; then
    export PATH="/usr/local/bin:$PATH"
    export PATH="$PATH:/Applications/VMware Fusion.app/Contents/Library"
fi

# Macports
#export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# 2014-06-25 bstiles: path to selectively override existing items on the path.
# This must be executed last so that overrides is at the head of the path.
export PATH="$HOME/bin/overrides:$HOME/bin/on-the-path:$PATH"

# 2013-07-23 bstiles: Force UTF8. psql under emacs behaves badly otherwise.
PGCLIENTENCODING=UTF8

if [ -n "$TMPDIR" -a "$(readlink $HOME/tmpdir)" != "$(dirname $TMPDIR)/$(basename $TMPDIR)" ]; then
    ln -sfn "$(dirname $TMPDIR)/$(basename $TMPDIR)" "$HOME/tmpdir"
fi

export JAVA_VERSION=1.7
export JAVA_HOME=$(/usr/libexec/java_home -version $JAVA_VERSION)
export VAGRANT_VMWARE_CLONE_DIRECTORY=~/Vagrant
