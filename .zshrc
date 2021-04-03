# sw:4
set -o autocd on
set -o sharehistory on
set -o shwordsplit on

HISTFILE=~/.bash_history

bindkey -e

# Reuse bash config as far as possible
autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

source /Users/dkrishnamurthy/.bashrc

fpath=(~/.local/share/git-completion/zsh $fpath)

# Write the completion script to somewhere in your $fpath
if [ ! -f ~/.zsh_functions/_atlas ]; then
    atlas --completion-script-zsh > ~/.zsh_functions/_atlas
fi

# For Mac using iTerm2
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "\e[3~"  delete-char

# Auto dir stack
DIRSTACKSIZE=8
setopt auto_pushd pushdminus pushdsilent pushdtohome
alias dh='dirs -v'

# Mimic the same bash command prompt
autoload -U colors && colors
export PS1=$fg_bold[blue]'%~'$reset_color'
$ '

# zsh equivalent for bash command execution hook
precmd() {
    if [ "${VIRTUAL_ENV}" = "" ] ; then
	export PS1="$fg_bold[blue]%~$reset_color
$ "
    else
	py=${VIRTUAL_ENV##*/}
	export PS1="[$fg_bold[red]$py$reset_color] $fg_bold[blue]%~$reset_color
$ "
    fi
    eval "$PROMPT_COMMAND"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"
