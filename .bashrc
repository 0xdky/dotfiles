#!/usr/bin/env bash
# vim:sw=4:expandtab

# PS4=$'\\\011%D{%s%6.}\011%x\011%I\011%N\011%e\011'
# setopt xtrace prompt_subst
set +x

set -o emacs
set -o pipefail

HOME=$(realpath ~)
USER=$(whoami)
OS=$(uname -s|tr '[A-Z]' '[a-z]')
SHELL=$(basename $SHELL)
export EDITOR=${EDITOR:-nvim}

# Python stuff
export  PYTHONDONTWRITEBYTECODE=1

export GO111MODULE=on
export GOPATH=${HOME}/devel/bitbucket/go
export GOBIN=${GOPATH}/bin/${OS}
export PATH=${GOBIN}:${PATH}

# Unlimited bash history
HISTSIZE=9999
SAVEHIST=${HISTSIZE}
HISTFILESIZE=${HISTSIZE}
HISTFILE=~/.bash_history

if [ -f /etc/bashrc.default ] ; then
    source /etc/bashrc.default
    return 0
fi

ulimit -c unlimited

if [ -z "$(launchctl getenv HOME)" ] ; then
    launchctl setenv HOME "${HOME}"
fi

# C/C++ compiler related
if [ -z "${LDFLAGS}" ] ; then
    LDFLAGS=-L/usr/local/lib
fi

# Ensure we find brew if available at the top
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/texinfo/bin:${PATH}

# Homebrew
LIB_PATH=/usr/local/lib
HEADER_PATH=/usr/local/include

# cling - C++ repl
CLING_HOME=${HOME}/installs/cling
CLING_HOME=/usr/local
alias cling='${CLING_HOME}/bin/cling --nologo -l ${HOME}/.clingrc'

# llvm from homebrew
LLVM_HOME=/usr/local/opt/llvm
# PATH=${LLVM_HOME}/bin:${PATH}
LIB_PATH=${LIB_PATH}:${LLVM_HOME}/lib
HEADER_PATH=${HEADER_PATH}:${LLVM_HOME}/include
LDFLAGS="${LDFLAGS} -L${LLVM_HOME}/lib -Wl,-rpath,${LLVM_HOME}/lib"
CPPFLAGS="-I${LLVM_HOME}/include ${CPPFLAGS}"

# asciidoc xml processing
export XML_CATALOG_FILES=/usr/local/etc/xml/catalog

# Rust compiler
source $HOME/.cargo/env

# tab completion for emacs similar to vim
compdef emacs=vim

if [ $OS = "darwin" ] ; then
    # To prevent ssh-agent on mac
    export SSH_AUTH_SOCK=""

    if [ $SHELL = "bash" ] ; then
	cmp_dir=$(brew --prefix)/etc/bash_completion.d
	if [ -d ${cmp_dir} ]; then
	    for f in ${cmp_dir}/* ; do
		! [[ $f =~ "micros" ]] && source $f
	    done
	fi
    elif [ $SHELL = "zsh" ] ; then
	fpath+=~/.zfunc
    fi

    export GOROOT=/usr/local/opt/go/libexec
    # export GO15VENDOREXPERIMENT=1

    # For bootstrapping Go from source
    export GOOS=darwin
    export GOARCH=amd64
    export GOROOT_BOOTSTRAP=/usr/local/opt/go/libexec
fi

# set the number of open files to be 1024
ulimit -S -n 1024

export ANDROID_NDK_HOME="/usr/local/share/android-ndk"
export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"

# For git
export LESS=-iFRX

# Atlassian specifics

# Useful aliases
alias ls='ls -CF'
alias md='mkdir -p'
alias vi=${EDITOR}
alias vimdiff="${EDITOR} -d"
alias cls='clear'
alias rgf='rg --files|rg'
alias docker-cleanup='docker images -a -q --filter "dangling=true"|xargs docker image rm -f'
# Java VScode plugin dumpyard
alias dumpyard='ls /Users/dkrishnamurthy/Library/Application\ Support/Code/User/workspaceStorage'
alias goupdate='TOP=`pwd`;for g in `find . -type d -name ".git"` ; do cd `dirname $g`; go get -u; cd $TOP; done'
alias gitstatus='git ls-files -z *[^vendor]|xargs -0 -n1 git blame --line-porcelain HEAD|grep "^author "|sort|uniq -c|sort -nr'
alias linux='docker run --rm --privileged=true -v ${HOME}:${HOME} --hostname=tinker -it linux'
alias crepl='cling --nologo -DCLING'
alias dns-cleanup='sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache'
alias gradle-publish='gradle clean build publishToMavenLocal printversion'
alias forall='repo forall -c'
alias ldd='otool -L'
alias ptpy='ptpython3'
alias h='history'
alias bbcgo='cd /Users/dkrishnamurthy/devel/bitbucket/go/src/bitbucket.org/bitbucket/go'
alias bbcgorel='echo release/$(date +"%Y%m%d")'
DEVUSR=dkrishnamurthy
alias devenv='mux ${DEVUSR}@${DEVUSR}.dev.devbucket.org'
alias em="/Applications/Emacs.app/Contents/MacOS/bin/emacsclient -q -a /Applications/Emacs.app/Contents/MacOS/Emacs -t -f ~/.emacs.d/server/emacs.server"
alias wscreate="hdiutil create -size 25gb -fs 'Case-sensitive HFS+' -type SPARSE -volname workspace workspace"
alias wsmount='hdiutil attach -quiet -mountpoint ~/workspace ~/Documents/workspace.sparseimage'
alias wsunmount='hdiutil detach -quiet ~/workspace'
alias netapp='plink -batch -pw $(cat ~/.ssh/netapp/ocum) admin@netapp.ash2.bb-inf.net'
alias jsh='jshell --startup ~/.jshellrc -q'

# rg (grep on steroids) customizations
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# Avoid duplicates
export HISTCONTROL=ignoredups:erasedups
# When the shell exits, append to the history file instead of overwriting it
if [[ $SHELL = *"bash"* ]] ; then
    if [ "${OS}" = "darwin" ] ; then
	PS1="\e[0;36m\w\e[m\n$ "
    else
	PS1="\e[0;31mdocker:\e[m\e[0;36m\w\e[m\n$ "
    fi
    shopt -s histappend
fi

# After each command, append to the history file and reread it
export PROMPT_COMMAND=prompt_command

# Refresh history on SIGUSR1
trap handle_sigusr1 SIGUSR1

#------------------------------------------------------------------------------
# Handle SIGUSR1 and do something more interesting
#------------------------------------------------------------------------------
function handle_sigusr1
{
    history -r
    trap handle_sigusr1 SIGUSR1
}

#------------------------------------------------------------------------------
# Execute when PROMPT is printed
#------------------------------------------------------------------------------
function prompt_command {
    # Clear garbled title from commands that set and forget the clear
    echo -ne "\033]0;\007"

    # Read commands from other shells - dangerous if blindly selecting previous
    # command!!!
    # history -a; history -c; history -r

    if [ -f ./.bashrc.local ]; then
	. ./.bashrc.local
    fi
}

function cloudIdToHostname() {
    echo "This is for staging only!"
    BASE_URL="https://tenant-context-service.internal.uswest.staging.atlassian.io/item"
    CLOUD_ID="$1"
    if [ -z "$1" ]; then
	echo "You need to provide a cloud ID."
	exit 1
    fi
    curl -XGET "$BASE_URL/$CLOUD_ID.cloudid.user-management" -s | jq .hostname
}

function hostnameToCloudId() {
    echo "This is for staging only!"
    BASE_URL="https://tenant-context-service.internal.uswest.staging.atlassian.io/item"
    CLOUD_ID="$1"
    if [ -z "$1" ]; then
	echo "You need to provide a cloud ID."
	exit 1
    fi
    curl -XGET "$BASE_URL/$CLOUD_ID.hostname.user-management" -s | jq .cloudId
}

function depcommit() {
    micros service:show -e $1 $2|egrep "^[ \t]+stable:[ \t]+"|awk -F"--" "{print \$3}"
}

function check_terminal_size
{
    stty columns $(tput cols)
}

if [ $OS = "darwin" ] ; then
    check_terminal_size
    trap 'check_terminal_size' WINCH
fi

function writetime
{
    local -i t=$1
    t=$t/1000000
    date -r $t
}

function bgit {
    if [ -z "$1" ] ; then
	echo "error: missing prefix for repo typeglob"
	return
    fi

    pattern="$1"
    shift

    dirs=(${pattern}*/.git)
    for d in "${dirs[@]%/.git}" ; do
	echo "# $d"
	${ACTION} git -C $d $*
    done
}

function tac {
    sed '1!G;h;$!d' $*
}

function whereis {
    if [ "" = "$1" ] ; then
	return
    fi

    for p in ${PATH//:/ }; do
	f="$p/$1"
	if [ -f $f -a -x $f ] ; then
	    echo $f
	fi
    done
}

function join_by {
    local IFS="$1"; shift; echo "$*";
}

function rmpath {
    local paths
    declare -i i=0
    for p in ${PATH//:/ }; do
	if [ "$p" != "$1" ] ; then
	    paths[$i]=$p
	    i=i+1
	fi
    done

    join_by : "${paths[@]}"
}

function android {
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-android-
    export CROSS_COMPILE_ARM32=arm-linux-androideabi-
    export PATH=/bin:${PATH}
    export PATH=${ANDROID_NDK_HOME}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin:${PATH}
    export PATH=${ANDROID_NDK_HOME}/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin:${PATH}
}

function brewclean {
    if [ $# -ge 1 ] ; then
	brew deps $1 | xargs brew remove --ignore-dependencies && brew missing | xargs brew install
    else
	echo "error: missing package name"
    fi
}

# Connect to tmux on remote node via ssh
function mux {
    ssh -t $1 tmux attach -d
}

# Update gcc-$version to gcc
function gcclink {
    if [ -z "$1" ] ; then
	echo "Error: Missing GCC version number"
	return -1
    fi

    for ii in `\ls -1 *-$1` ; do
	base=`echo $ii|sed s#-9##g`
	${ACTION} cp -nP $ii $base
    done
}

MICROSEXE="atlas micros"
function micros() {
    if [ "$1" = "ssh" ]; then
	cmd=$1
	shift
	ARGS="service ssh --exception-group bitbucket-cloud-dce-dl-admin $@"
    else
	ARGS="$@"
    fi

    ${ACTION} ${MICROSEXE} $ARGS
}

AWSEXE=`which aws`
function faws() {
    ${ACTION} ${AWSEXE} --endpoint-url http://localhost:9324 "$@"
}
export AWS_SDK_LOAD_CONFIG=1
export SQS_QUEUE_URL=http://localhost:9324/queue/sync

function mkgtags() {
    pushd ~/.tags

    incpath=/usr/include:/usr/local/include:/Library/Developer/CommandLineTools/usr/include
    incpath=${incpath}:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include

    dirs=
    incpath=("${(@s/:/)incpath}")
    for d in ${incpath}; do
	if [ -d ${d} ] ; then
	    dirs="$dirs ${d}"
	    t=$(echo $d|tr '/' '_')
	    ${ACTION} ln -s ${d} ${t}
	fi
    done

    echo ${dirs}
    ${ACTION} rg -L --files -g "*.h" > ~/.tags/files
    ${ACTION} gtags -f ~/.tags/files ~/.tags

    popd
}

function ioload_summary() {
    grep -E '^[a-zA-Z]' $*|datamash -H -R 2 -s -t , -g 1 mean 2 median 2 count 1 pstdev 2 sstdev 2
}

function review() {
    if [ $# -lt 2 ] ; then
	return -1
    fi

    base=$1
    other=$2

    files=($(git diff --name-only ${base}..${other} 2>/dev/null))
    PROMPT3="select [x to exit]: "
    select file in ${files[@]}; do
	case $file in
	    *"1 to quit"*)
		break
		;;
	    *)
		if [[ "${REPLY}" =~ "^[0-9]+$" ]] ; then
		    if [ $REPLY -le $#files ] ; then
			git difftool -t vimdiff ${base}..${other} ${file} 2>/dev/null
		    fi
		elif [ "${REPLY}" = "x" ] ; then
		    echo "done..."
		    break
		else
		    echo "invalid input: $REPLY, retry"
		fi
		;;
	esac
    done
}

DOCKER_EXE=$(which docker)
function docker() {
    cmd=$1
    if [ $# -ne 0 ]; then
	shift
    fi

    if [ "${cmd}" = "shell" ] ; then
        ${ACTION} ${DOCKER_EXE} run -it --rm --privileged -v $(realpath ~):/home $* bash -c "cd /home; bash -l"
    else
	args=$(echo $*|sed 's#-ep #--entrypoint=#')
        ${ACTION} ${DOCKER_EXE} ${cmd} ${args}
    fi
}

# Search and open in editor
function rged() {
    ${ACTION} ${EDITOR} $(rg -l $*) +/$*
}

function neovim_update() {
    os=${1:-${OS}}
    if [ "${os}" = "darwin" ] ; then
	plat="macos"
    elif [ "${os}" = "linux" ] ; then
	plat="linux64"
    else
	echo invalid platform: ${os}
	return -1
    fi

    mkdir -p ~/installs/${os}
    pushd ~/installs/${os}
    set -x
    curl -sL https://github.com/neovim/neovim/releases/download/nightly/nvim-${plat}.tar.gz|tar --strip-components=1 -zxf -
    set +x
    popd
}

function pipupgrade() {
    PIP=${1:-pip3}
    ${PIP} list -o --format json|jq -s ".[][].name"|tr -d \"|xargs ${PIP} install -U
}

function urlencode() {
    python -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))" $*
}

function urldecode() {
    python -c "import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.argv[1]))" $*
}

# pf-directory is built with TypeScript!
export NVM_DIR="${HOME}/.nvm"
[ -f /usr/local/opt/nvm/nvm.sh ] && . /usr/local/opt/nvm/nvm.sh
ulimit -n 16384  # Increases the number of open files
export PGHOST=$(hostname)

# This assumes that the macOS machine has 8 threads
export MAKEFLAGS='-j8'

# Set it at the end so that ~/bin takes precedence
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# jenv configuration *magic*
PATH="/Users/dkrishnamurthy/.jenv/shims:${PATH}"
jenv rehash 2>/dev/null
export JENV_LOADED=1
jenv() {
  typeset command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  enable-plugin|rehash|shell|shell-options)
    eval `jenv "sh-$command" "$@"`;;
  *)
    command jenv "$command" "$@";;
  esac
}

if [ $OS = "darwin" ] ; then
    JAVA_HOME=$(launchctl getenv JAVA_HOME)
    if [ -z "${JAVA_HOME}" ] ; then
	export JAVA_HOME=$(dirname $(dirname $(jenv which javac)))
	echo "Setting system wide JAVA_HOME: ${JAVA_HOME}"
	launchctl setenv JAVA_HOME "${JAVA_HOME}"
    fi
fi
export MAVEN_OPTS="-Xmx2g -XX:MaxMetaspaceSize=512m"

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# No time for experimenting with Graal
# GRAALVM_HOME=/Applications/graalvm-ce/Contents/Home
# PATH=${GRAALVM_HOME}/bin:${PATH}

MANPATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/share/man:/usr/local/share/man:/usr/share/man:$MANPATH

PATH="/usr/local/opt/gettext/bin:$PATH"
LIB_PATH="${LIB_PATH}:/usr/local/opt/openssl/lib:/usr/local/opt/gettext/lib"
HEADER_PATH="${HEADER_PATH}:/usr/local/opt/openssl/include:/usr/local/opt/gettext/include"

# find -L /usr/local/opt -type d -name pkgconfig|tr ':' '\n'|grep -v 2.7|sort|uniq|tr '\n' ':'
# export PKG_CONFIG_PATH=...

# For postgres
# export PKG_CONFIG_PATH="/usr/local/opt/postgresql@11/lib/pkgconfig"

# Postgres binaries
# PATH=/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH
# DLD_LIBRARY_PATH=/Applications/Postgres.app/Contents/Versions/latest/lib:$DLD_LIBRARY_PATH

# Jailbreaking
export AZULE=~/stub/git/Azule

# For bitbucket-docker
export NPMRC="$(launchctl getenv NPMRC)"
if [ -z "${NPMRC}" ] ; then
    export NPMRC="$(cat ~/.npmrc)"
    launchctl setenv NPMRC "${NPMRC}"
fi

export SSH_KEY="$(launchctl getenv SSH_KEY)"
if [ -z "${SSH_KEY}" ] ; then
    export SSH_KEY="$(openssl rsa -in ~/.ssh/id_rsa 2>/dev/null)"
    launchctl setenv SSH_KEY "${SSH_KEY}"
fi

for p in `echo ${LIB_PATH} | tr ':' ' '`; do
    LDFLAGS="${LDFLAGS} -L${p}"
done

for p in `echo ${HEADER_PATH} | tr ':' ' '`; do
    CPPFLAGS="${CPPFLAGS} -I${p}"
done

# Eliminate duplicates in PATH
declare -A paths
_path="${HOME}/bin:${HOME}/installs/${OS}/bin"
for p in `echo ${PATH} | tr ':' ' '` ; do
    if [ -z "${paths[$p]}" ] ; then
	paths[$p]=$p
	_path=${_path}:$p
    fi
done
PATH=${_path}
unset _path

export PATH CPPFLAGS LDFLAGS MANPATH PYTHONPATH GTAGSLIBPATH

# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# eval "$(zoxide init bash)"
