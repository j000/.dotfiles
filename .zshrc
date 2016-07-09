# Shell is non-interactive. Be done now!
[[ $- != *i* ]] && return

# autologout on tty* after 10 minutes
[[ $(tty) =~ /dev\/tty* ]] && TMOUT=600

#######################################

fpath=(~/.config/zsh/completion $fpath)

zstyle ':completion:*' auto-description 'Specify: %d'
zstyle ':completion:*' completer _complete _approximate _expand _ignored
zstyle ':completion:*' format ' -  %d  - '
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=0
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/j000/.zshrc'

autoload -Uz compinit
compinit
#######################################

zstyle ':completion:*:sudo::' environ PATH="/usr/local/sbin:/usr/sbin:/sbin${PATH:+:$PATH}" HOME="/root"
zstyle ':completion:*:slow::' environ PATH="/usr/local/sbin:/usr/sbin:/sbin${PATH:+:$PATH}" HOME="/root"

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' command 'ps -u $USER --forest -o pid,%cpu,cputime,cmd'
zstyle ':completion:*:*:kill:*:jobs' verbose no

compdef _pids wait_on_pid
zstyle ':completion:*:*:wait_on_pid:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:wait_on_pid:*' command 'ps -u $USER --forest -o pid,%cpu,cputime,cmd'
zstyle ':completion:*:*:wait_on_pid:*:jobs' verbose no

compdef _hub git

zstyle ':completion::complete:*' use-cache 1

#######################################

REMATCH_PCRE=1
zmodload zsh/pcre

zshaddhistory () {
	# return 0 -> save in history, stays in memory
	# return 1 -> no history, no memory
	# return 2 -> no history, stays in memory
	
	# http://www.zsh.org/mla/users//2014/msg00715.html
	whence ${${(z)1}[1]} >/dev/null || return 1
	
	# don't store some commands
	# use HISTORY_IGNORE and HISTORY_SKIP
	pcre_compile "(\b(${HISTORY_SKIP})\b)"
	pcre_match -- ${1%%$'\n'} && return 1
	pcre_compile "(\b(${HISTORY_IGNORE})\b)"
	pcre_match -- ${1%%$'\n'} && return 2
	return 0
}

HISTFILE=~/.config/zsh/histfile
HISTSIZE=3000
HISTORY_SKIP='fuck|fg|bg|exit'
HISTORY_IGNORE='man|ls|rm|cd'
SAVEHIST=3000
setopt append_history
#setopt inc_append_history
setopt share_history
setopt hist_fcntl_lock
setopt hist_lex_words
setopt hist_no_store
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt no_hist_beep
REPORTTIME=10
TIMEFMT='time:%*E  user:%U system:%S  %P cpu  memory:%Kk max:%MM  %J'
setopt no_beep
setopt auto_cd
setopt glob_dots
setopt extended_glob
setopt notify
setopt complete_aliases
setopt glob_complete
setopt auto_continue
setopt check_jobs
setopt no_hup
bindkey -e

#######################################

# adv key support
local OLDZDOTDIR=$ZDOTDIR
ZDOTDIR=~/.config/zsh
. ~/.config/zsh/keys.adv
ZDOTDIR=$OLDZDOTDIR

#######################################

# tmux functions
. ~/.config/zsh/tmux

#if [[ -z "$TMUX" ]] ; then # if not in tmux
#	read -t5 -q "ANS?Skip main tmux session? [y/N]"
#	local tmp=$?
#	if [[ tmp -eq 0 ]] ; then
#		echo " Skipping tmux..."
#	else
#		tmx
#	fi
#fi

#######################################

#source ~/.config/zsh/notify/notify.plugin.zsh

#######################################

= () {
	if [[ $# -ge 1 ]] ; then
		echo "$@" | bc -l
	else
		bc -l
	fi
}

#######################################

pidtree () {
	if [[ $# -gt 1 ]]; then
		for var in "@$"; do
			pidtree $var
		done
	else
		echo -n "$1 "
		for _child in $(ps -o pid --no-headers --ppid $1); do
			pidtree $_child
		done
	fi
}

pidtree () {
	declare -A CHILDS
	ps -e -o pid= -o ppid= | while read P PP; do
		CHILDS[$PP]+=" $P"
	done
	walk() {
		echo -n "$1 "
		for i in ${CHILDS[$1]}; do
			walk $i
		done
	}
	for i in $@;do
		walk $i
	done
}

#######################################

#preexec () {
#	if [[ "$TERM" =~ "screen" ]]; then
#		local CMD=${1[(wr)^(*=*|sudo|slow|low|nice|ionice|schedtool|watch|-*)]}
#		echo -n "\ek$CMD\e\\"
#	fi
#}

#precmd () {
#	echo -n "\ekzsh\e\\"
#}

#######################################

#PS1='%(?.%{%F{green}%}✓.%{%F{red}%}✗ %?)%{%f%} %{%F{green}%}%~%{%f%}%(!.%{%F{red}%}#.%{%F{blue}%}>)%{%f%} '
#PS1='%(?.%{%F{green}%}+.%{%F{red}%}X %?)%{%f%} %{%F{green}%}%~%{%f%}%(!.%{%F{red}%}#.%{%F{blue}%}>)%{%f%} '
PS1='%(?.%{%F{green}%}♪.%{%F{red}%}X %?)%{%f%} %{%F{green}%}%-40<...<%~%{%f%}%(!.%{%F{red}%}#.%{%F{blue}%}>)%{%f%} '
PS2='%{%F{green}%}%5_%{%F{blue}%}>%{%f%} '

# vcs prompt
setopt PROMPT_SUBST
ZLE_RPROMPT_INDENT=1
# downloaded part # FIXME

ZSH_VCS_PROMPT_AHEAD_SIGIL=${ZSH_VCS_PROMPT_AHEAD_SIGIL:-'> '}
ZSH_VCS_PROMPT_BEHIND_SIGIL=${ZSH_VCS_PROMPT_BEHIND_SIGIL:-'< '}
ZSH_VCS_PROMPT_STAGED_SIGIL=${ZSH_VCS_PROMPT_STAGED_SIGIL:-'^ '}
ZSH_VCS_PROMPT_CONFLICTS_SIGIL=${ZSH_VCS_PROMPT_CONFLICTS_SIGIL:-'! '}
ZSH_VCS_PROMPT_UNSTAGED_SIGIL=${ZSH_VCS_PROMPT_UNSTAGED_SIGIL:-'● '}
ZSH_VCS_PROMPT_UNTRACKED_SIGIL=${ZSH_VCS_PROMPT_UNTRACKED_SIGIL:-'… '}
ZSH_VCS_PROMPT_STASHED_SIGIL=${ZSH_VCS_PROMPT_STASHED_SIGIL:-'⚑ '}
ZSH_VCS_PROMPT_CLEAN_SIGIL=${ZSH_VCS_PROMPT_CLEAN_SIGIL:-'♪ '}

ZSH_VCS_PROMPT_LOGGING_THRESHOLD_MICRO_SEC=1

## normal
# vcs name
ZSH_VCS_PROMPT_GIT_FORMATS='#s '
# branch
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%B%}%{%F{cyan}%}#b%{%f%} '
# ahead and behind
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%F{blue}%}#c%{%f%}%{%F{magenta}%}#d%{%f%}'
# staged
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%F{green}%}#e%{%f%}'
# unstaged
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%F{yellow}%}#g%{%f%}'
# untracked
ZSH_VCS_PROMPT_GIT_FORMATS+='#h'
# conflicts
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%F{red}%}#f%{%f%}'
# stashed
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%F{cyan}%}#i%{%f%}'
# clean
ZSH_VCS_PROMPT_GIT_FORMATS+='%{%F{green}%}#j%{%f%}%{%b%}'

## action
# vcs name
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS='#s '
# branch
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%B%}%{%F{cyan}%}#b%{%f%} '
# action
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+=':%{%F{red}%}#a%{%f%} '
# ahead and behind
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%F{blue}%}#c%{%f%}%{%F{magenta}%}#d%{%f%}'
# staged
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%F{green}%}#e%{%f%}'
# conflicts
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%F{green}%}#j%{%f%}%{%b%}'
# unstaged
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%F{yellow}%}#g%{%f%}'
# untracked
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='#h'
# stashed
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%F{cyan}%}#i%{%f%}'
# clean
ZSH_VCS_PROMPT_GIT_ACTION_FORMATS+='%{%F{green}%}#j%{%f%}%{%b%}'

## other vcs
# vcs name
ZSH_VCS_PROMPT_VCS_FORMATS='#s '
# branch name
ZSH_VCS_PROMPT_VCS_FORMATS+='%{%B%F{cyan}%}#b%{%f%b%}'
## action
# vcs name
ZSH_VCS_PROMPT_VCS_ACTION_FORMATS='#s '
# branch name
ZSH_VCS_PROMPT_VCS_ACTION_FORMATS+='%{%B%F{cyan}%}#b%{%f%}'
# action
ZSH_VCS_PROMPT_VCS_ACTION_FORMATS+=':%{%F{red}%}#a%{%f%b%}'

ZSH_VCS_PROMPT_ENABLE_CACHING='true'
ZSH_VCS_PROMPT_USING_PYTHON='true'
. ~/.config/zsh/vcs/zshrc.sh
#. ~/.config/zsh/vcs.sh
RPROMPT='%(1j,%{%F{red}%}(%j%)%{%f%},) $(vcs_super_info)'

#######################################

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    bg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

#######################################

disk_state() {
	if (( $# == 0 )); then
		echo 'Give me disk!'
		return 127
	else
		sudo smartctl -i -n standby $1 | grep -e STANDBY -e ACTIVE; sudo hdparm -C $1 | grep state
	fi
}

#######################################

PATH="${PATH:+$PATH:}/home/j000/.gem/ruby/2.2.0/bin"
WINEARCH='win32'

alias -g egrep='egrep --colour=auto'
alias -g fgrep='fgrep --colour=auto'
alias -g grep='grep --colour=auto'
alias -g ls='ls --color=auto'
alias -g watch='watch -c '
#alias -g schedule='schedule --no-host '
# alias -g make='make -j2 -l2'
#alias man='pinfo'
alias -g gdemerge='FETCHCOMMAND="/usr/bin/getdelta.sh \${URI}" emerge'

alias tmx2='exec tmux new-session -A -s main'

#alias temp='nvidia-settings -tdq :0.0/gpucoretemp; sensors'
#alias temp="DISPLAY=:0 nvidia-settings -tdq ':0.0/gpucoretemp' | sed -e 's/^\([0-9]\+\)$/GPU: \t\1\xc2\xb0C/'; sensors | sed -e's/^Core \([01]\)[^(]*+\([0-9]\+\)\..*$/Core\1: \t\2\xc2\xb0C/p' -e'd'"
alias temp="nvidia-smi --format=csv,noheader --query-gpu=temperature.gpu,fan.speed | sed -e 's/^\([0-9]\+\), \([0-9]\+\) %$/GPU: \t\1\xc2\xb0C, FAN: \2%/'; sensors | sed -e's/^Core \([0-9]\)[^(]*+\([0-9]\+\)\..*$/Core\1: \t\2\xc2\xb0C/p' -e'd'"
alias tbw2='sudo smartctl -l devstat /dev/sda | awk '"'"'/Logical Sectors Written/ { print "TBW:\t"($4 / 2.0) /1024 /1024 /1024 "\t("($4 / 2.0) /1024 " MiB)" }'"'"
alias tbw='sudo smartctl -A /dev/sda | awk '"'"'BEGIN {hours=0}; /^  9/ {hours=($10+1); print $2":\t\t"$10}; /^24[125]/ { total=($10 * 32.0); print $2":\t"$10"\t"total/1024" GiB\t("(total/(hours*60*60))" MiB/s)" }'"'"'; echo "2 GiB/dzień (0.57 MiB/s) przez 5 lat bez przerwy"'
alias tbw='sudo smartctl -A /dev/sda |
	awk '"'"'BEGIN {"datediff 2016-02-17T12:00:00 now -f %H" | getline; rhours=$1; hours=0};
		/^  9/ {hours=($10+1); print $2":\t\t"$10"\t(total "rhours")"};
		/^24[125]/ { total=($10 * 32.0); print $2":\t"$10"\t"total/1024" GiB\t("(total/(hours*60*60))" MiB/s)\t("total/(rhours*60*60)" MiB/s)" }'"'"';
	echo "2 GiB/dzień (0.57 MiB/s) przez 5 lat bez przerwy"'

alias folding-pause='/opt/foldingathome/FAHClient --send-pause'
alias folding-unpause='/opt/foldingathome/FAHClient --send-unpause'
alias transmission='transmission-remote redqueen:22223 -n tor:hores'
alias emacs='emacs -nw'

alias clear='clear; [[ -n $TMUX ]] && tmux clear-history'
alias mute='amixer sset Speaker 0'
alias vol='amixer sset Speaker'
alias -g vlc-stop='dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop'
alias -g vlc-play='dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Play'

alias -g low='ionice -c3 schedtool -D -e '
compdef _precommand \low
alias slow='low sudo '
compdef _sudo slow

alias restart-router="curl -c ./cookies -d 'LOGIN_USER=admin' -d 'LOGIN_PASSWD=' -d 'ACTION_POST=LOGIN' 'http://192.168.0.1/login.php' && curl 'http://192.168.0.1/sys_cfg_valid.xgi?&exeshell=submit%20REBOOT'"

#alias makekernel='slow make silentoldconfig && slow make modules_prepare && slow make && slow emerge --ask=n @module-rebuild && slow make install && slow make modules_install && slow grub2-mkconfig -o /boot/grub/grub.cfg && echo "Done!"'
alias eclean-kernel='sudo eclean-kernel -x initramfs'

eval "$(hub alias -s)"
eval "$(thefuck --alias)"
