# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

PS1='[\[\033[00;36m\]\t\[\033[00m\]] \[\e[1;31m\]\u\[\033[01;32m\]@\[\033[01;36m\]\h \[\033[01;34m\] (\w) >\[\033[00m\] '
