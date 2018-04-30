#!/bin/bash
# Bootstrap new MacOS X installation.
# ad, 2018
#
# Inspired by https://github.com/divio/osx-bootstrap

# Declare main variables.
declare version="master"
declare source_dir=~/.osx-bootstrap
declare remote_source="https://github.com/0x4e3/osx-bootstrap.git"

# sudo keepalive
startsudo() {
    sudo -v
    ( while true; do sudo -v; sleep 60; done; ) &
    SUDO_PID="$!"
    trap stopsudo SIGINT SIGTERM
}

stopsudo() {
    kill "$SUDO_PID"
    trap - SIGINT SIGTERM
    sudo -k
}

install_or_update() {
    command -v git >/dev/null 2>&1 || {
        printf "${RED}Error: git is not installed${NORMAL}\n"
        exit 1
    }

    if [ ! -d $source_dir ]; then
        printf "${BLUE}Downloading Bootstrap...${NORMAL}\n"
        env git clone $version $remote_source $source_dir || {
            printf "${RED}Error: git clone of bootstrap repo failed${NORMAL}\n"
            exit 1
        }
    else
        printf "${BLUE}Updating Bootstrap files...${NORMAL}\n"
        cd $source_dir
        env git pull origin $version
    fi
}

ansible_galaxy() {
    env ansible-galaxy install -r $source_dir/requirements.yml --force
}

ansible() {
    env ansible-playbook $source_dir/playbook.yml
}

main() {
    if which tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        NORMAL="$(tput sgr0)"
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        NORMAL=""
    fi

    install_or_update

    printf "${BLUE}"
    echo '#######################'
    echo 'OSX Bootstrap' $version
    echo '#######################'
    printf "${NORMAL}\n"

    startsudo

    printf "${BLUE}Installing required roles from ansible-galaxy...${NORMAL}\n"
    ansible_galaxy

    printf "\n"

    printf "${BLUE}Playing hard to configure your workstation...${NORMAL}\n"
    ansible

    printf "\n"

    stopsudo

    printf "${GREEN}"
    echo '#######################'
    cowsay 'Bootstrap Ready!'
    echo '#######################'
    printf "${NORMAL}"
}

main
