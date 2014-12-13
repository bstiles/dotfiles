# -*- mode: sh -*-
##
## This is executed for each login shell (sourced by .bash_profile
## when bash is used).
##

# 2012-12-18 bstiles: Haskell goodies
export PATH="$HOME/.cabal/bin:$PATH"

# 20140610 bstiles: Add VMWare Fusion command line tools
export PATH="$PATH:/Applications/VMware Fusion.app/Contents/Library"

# Macports
#export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# 2014-06-25 bstiles: path to selectively override existing items on the path.
# This must be executed last so that overrides is at the head of the path.
export PATH="$HOME/bin/overrides:$HOME/bin/on-the-path:$PATH"

# 2013-07-23 bstiles: Force UTF8. psql under emacs behaves badly otherwise.
PGCLIENTENCODING=UTF8

if [ "$(readlink $HOME/tmpdir)" != "$(dirname $TMPDIR)/$(basename $TMPDIR)" ]; then
    ln -sfn "$(dirname $TMPDIR)/$(basename $TMPDIR)" "$HOME/tmpdir"
fi

export JAVA_HOME=$(/usr/libexec/java_home -version 1.7)
