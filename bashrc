# -*- mode: sh -*-
##
## This is executed for each interactive Bash shell (unless started
## with sh). A good place for aliases and prompts.
##

shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=5000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%m-%d %H:%M  '

# 2014-12-12 bstiles: Make sure .profile is sourced in the case where
# we've come in via 'ssh -t tmux' or the like.
if [[ ! $- == *i* ]]; then
    . /etc/profile
    . "$HOME/.profile"
fi

# Warn if ~/bin/overrides isn't at the head of the PATH.
[[ $(echo $PATH | tr : '\n' | head -1) =~ .*bin/overrides ]] \
    || cat <<EOF
WARNING!
WARNING!
WARNING! ~/bin/overrides is not at the head of PATH. Check ~/.bash_profile for tampering.
WARNING!
EOF

set completion-ignore-case on

. "$HOME/.bash_alias"

######################################################################
## GnuPG
##

GPG_TTY=$(tty)
export GPG_TTY

######################################################################
## Emacs
##

if [ "$EMACS" = "t" ]
then
    TERM=emacsclient
fi

which emacsclient-t.sh >/dev/null && export VISUAL=$(which emacsclient-t.sh)

######################################################################
## Prompt
##

GIT=$(which git)

function parse_git_branch {
    if [ -z "$GIT" ]; then return; fi
    local ref=$($GIT branch 2> /dev/null | grep '*' | awk '{ print $2; }')

    if [ -z "$ref" ]
    then
        return
    elif [ "$ref" = "(no" ]
    then
        ref="DETACHED"
    fi
    echo -n "$ref"
}

if [ "${TERM:-dumb}" != "dumb" ]; then
    if [ "$TERM" = "emacsclient" ]; then
        TERM_TYPE=-Txterm-256color
    else
        TERM_TYPE=
    fi

    bold=$(tput $TERM_TYPE bold)

    bg_black=$(tput $TERM_TYPE setab 0)
    bg_red=$(tput $TERM_TYPE setab 1)
    bg_green=$(tput $TERM_TYPE setab 2)
    bg_yellow=$(tput $TERM_TYPE setab 3)
    bg_blue=$(tput $TERM_TYPE setab 4)
    bg_magenta=$(tput $TERM_TYPE setab 5)
    bg_cyan=$(tput $TERM_TYPE setab 6)
    bg_white=$(tput $TERM_TYPE setab 7)

    bg_black_intense="${bg_black}${bold}"
    bg_red_intense="${bg_red}${bold}"
    bg_green_intense="${bg_green}${bold}"
    bg_yellow_intense="${bg_yellow}${bold}"
    bg_blue_intense="${bg_blue}${bold}"
    bg_magenta_intense="${bg_magenta}${bold}"
    bg_cyan_intense="${bg_cyan}${bold}"
    bg_white_intense="${bg_white}${bold}"

    fg_black=$(tput $TERM_TYPE setaf 0)
    fg_red=$(tput $TERM_TYPE setaf 1)
    fg_green=$(tput $TERM_TYPE setaf 2)
    fg_yellow=$(tput $TERM_TYPE setaf 3)
    fg_blue=$(tput $TERM_TYPE setaf 4)
    fg_magenta=$(tput $TERM_TYPE setaf 5)
    fg_cyan=$(tput $TERM_TYPE setaf 6)
    fg_white=$(tput $TERM_TYPE setaf 7)

    fg_black_intense="${fg_black}${bold}"
    fg_red_intense="${fg_red}${bold}"
    fg_green_intense="${fg_green}${bold}"
    fg_yellow_intense="${fg_yellow}${bold}"
    fg_blue_intense="${fg_blue}${bold}"
    fg_magenta_intense="${fg_magenta}${bold}"
    fg_cyan_intense="${fg_cyan}${bold}"
    fg_white_intense="${fg_white}${bold}"

    if [[ $TERM == *256* ]]; then
        bg_dark_gray=$(tput setab 234)
        bg_dark_gray_intense="${bg_dark_gray}${bold}"
        fg_dark_gray=$(tput setaf 234)
        fg_dark_gray_intense="${fg_dark_gray}${bold}"
    else
        bg_dark_gray=$bg_black
        bg_dark_gray_intense=$bg_black_intense
        fg_dark_gray=$fg_black
        fg_dark_gray_intense=$fg_black_intense
    fi

    # 2014-12-12 bstiles: tput sgr0 doesn't work under emacs for some
    # reason.
    if [ "$TERM" = "emacsclient" ]; then
        default="\e[0m"
    else
        default="$(tput $TERM_TYPE sgr0)"
    fi
fi

function in_emacs {
    [[ $TERM = emacsclient || $TERM = eterm-color ]]
}

function prompt_info {
    # Beautify the prompt.
    local EXIT=$?
    local normal="\[${bg_dark_gray}${fg_white}\]"
    local dim="\[${bg_dark_gray}${fg_black}\]"
    local dim_highlight="\[${bg_dark_gray}${fg_yellow}\]"
    local highlight="\[${bg_dark_gray}${fg_white_intense}\]"
    local git_branch="\[${bg_dark_gray}${fg_cyan}\]"
    local error="\[${fg_red_intense}\]"
    local off="\[${default}\]"

    # Append to history on every command.
    history -a

    ## Previous command stats ---------
    # Gutter
    PS1="${off}${normal}"

    # Last exit status
    PS1+="[exit "
    if [ $EXIT -eq 0 ]; then
        PS1+="${EXIT}]"
    else
        PS1+="${error}${EXIT}${off}${normal}]"
    fi
    PS1+="${dim}"
    case $EXIT in
        [0-9])
            PS1+=" =="
            ;;
        [0-9][0-9])
            PS1+=" ="
            ;;
        *)
            PS1+=" "
            ;;
    esac
    PS1+="=================================================== ${off}${normal}"

    # Time
    PS1+="[\A]"
    PS1+="${off}\n"

    ## Location -----------------------
    # Working directory
    if ! in_emacs; then
        PS1+="${normal}                                                                      ${off}\r"
    fi
    PS1+="${highlight}\w${off}"

    # Git Branch
    local branch=$(parse_git_branch)
    if [ -n "$branch" ]; then
        PS1+="${normal} [${git_branch}${branch}${off}${normal}]${off}"
    fi

    PS1+="${normal} \u@${dim_highlight}\h"
    PS1+="${off}\n"

    ## Prompt -------------------------
    if [ "$BASH_VERSINFO" = "3" ]; then
        PS1+="${dim_highlight}Bash 3 "
    fi

    if in_emacs && [[ $SHLVL -gt 1 ]] || ! in_emacs && [[ ! "$0" =~ -.* ]]; then
        local nested="${dim_highlight}[nested]${normal} "
    fi
    
    PS1+="${normal}${nested:-}${highlight}\\\$${off} "
    PS2="${normal} >${off} "
}
PROMPT_DIRTRIM=3
if [ -n "$TERM" ]; then
    PROMPT_COMMAND="prompt_info"
else
    PS1='\u@\h \$'
fi
