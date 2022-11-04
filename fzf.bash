# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
# 2020-12-16 bstiles: FZF Broke C-t handling. Previously, we could
# just re-bind C-t to transpose, but now that breaks C-r for some reason.
if [[ $(shasum /usr/local/opt/fzf/shell/key-bindings.bash) != '4fd64b023321cfa7be1b243fb744d2e3e857e9df  /usr/local/opt/fzf/shell/key-bindings.bash' ]]; then
    cat <<EOF
WARNING!
WARNING! .fzf.bash:
WARNING! /usr/local/opt/fzf/shell/key-bindings.bash has changed.
WARNING! Synchronize with ~/Config/dotfiles/fzf-fix-key-bindings.bash
WARNING!
EOF
fi
#source "/usr/local/opt/fzf/shell/key-bindings.bash"
source ~/.fzf-fix-key-bindings.bash

# 2020-02-15 bstiles: Take back C-t
# bind '"\C-t": transpose-chars'

# 2020-02-12 bstiles: Customizations

export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'

# To apply the command to COMMAND-C as well
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

export FZF_TMUX=1
