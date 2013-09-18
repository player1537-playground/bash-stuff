# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
    *)
	;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
alias ed="ed -p:"
alias em="emacsclient"
export PATH=$PATH:$HOME/bin/
export EDITOR="emacsclient -t"

PRINT_MINIMAL=
PRINT_LS=
LAST_COMMAND=
alias cd=mycd
function mycd() {
    \cd "$@" || return
    export PWD
    if [ -n "$PRINT_LS" ]; then
	clear
	ls
    fi
}
function moar() {
    case "do$1" in
	dols) 
	    if [ -n "$PRINT_LS" ]; then
		PRINT_LS=
	    else
		PRINT_LS=yes
	    fi
	    ;;
	do)
	    if [ -n "$PRINT_MINIMAL" ]; then
		PRINT_MINIMAL=
	    else	
		PRINT_MINIMAL=yes
	    fi
	    ;;
    esac
}
function prompt_command() {
    local cols pwd colors time ret sep lastret
    lastret=$1
    cols=$(tput cols)
    pwd="${PWD//${HOME}/~}"
    date=$(date +%R)
    ret=
    declare -A colors
    colors[Black]='\033[0;30m'
    colors[DarkGray]='\033[1;30m'
    colors[Blue]='\033[0;34m'
    colors[LightBlue]='\033[1;34m'
    colors[Green]='\033[0;32m'
    colors[LightGreen]='\033[1;32m'
    colors[Cyan]='\033[0;36m'
    colors[LightCyan]='\033[1;36m'
    colors[Red]='\033[0;31m'
    colors[LightRed]='\033[1;31m'
    colors[Purple]='\033[0;35m'
    colors[LightPurple]='\033[1;35m'
    colors[Brown]='\033[0;33m'
    colors[Yellow]='\033[1;33m'
    colors[LightGray]='\033[0;37m'
    colors[White]='\033[1;37m'
    colors[None]='\033[0m'
    colors[Underline]='\033[4m'
    ret=
    if [ ! "$PRINT_MINIMAL" = yes ]; then
	sep="${colors[Yellow]}|${colors[None]}"
	ret+="${colors[Yellow]}[ ${colors[Blue]}${colors[Underline]}$pwd${colors[None]} "
	ret+="$sep "
	ret+="${colors[Blue]}$date${colors[None]} ${colors[Yellow]}]${colors[None]} "
	ret+="${colors[Yellow]}-"
	if [ $lastret = 0 ]; then
	    ret+="${colors[Green]}"
	else
	    ret+="${colors[Red]}"
	fi
	ret+="$(x - $((cols - ${#pwd} - ${#date} - 10)))${colors[None]}"
	ret+="${colors[Yellow]}-${colors[None]}"
	ret+="\n"
    fi
    ret+="   "
    echo -e "$ret"
}
PS1="\$(prompt_command \$?)"
alias z="source $HOME/.bashrc"
alias -- -='cd ..'

function _work() { 
  local cur
  _get_comp_words_by_ref cur
  cd /media/3764-3031/tanner/src/
  _filedir
  _expand
} 
complete -F _work work

export BROWSER=$HOME/bin/conkeror
function mvcd() { mv "$@"; cd $_; }
