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
source "/usr/local/opt/fzf/shell/key-bindings.bash"

# 2020-02-15 bstiles: Take back C-t
bind '"\C-t": transpose-chars'

# 2020-02-12 bstiles: Customizations

export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'

# To apply the command to COMMAND-C as well
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

export FZF_TMUX=1
