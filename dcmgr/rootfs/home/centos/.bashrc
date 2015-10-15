# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions
PS1='[\[\033[00;36m\]\t\[\033[00m\]] \[\033[01;32m\]\u@\[\033[01;36m\]\h \[\033[01;34m\] (\w) >\[\033[00m\] '
