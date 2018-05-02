#!/bin/bash
# Bootstrap new MacOS X installation.
# ad, 2018
#
# Inspired by https://github.com/divio/osx-bootstrap

# Declare main variables.
declare version="master"
declare source_dir=~/.osx-bootstrap
declare remote_source="https://github.com/0x4e3/osx-bootstrap.git"
declare host_name="adBook"

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

set_hostname() {
    sudo scutil --set ComputerName $host_name
    sudo scutil --set HostName $host_name
    sudo scutil --set LocalHostName $host_name
}

install_or_update_bootstrap() {
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

install_command_line_tools() {
    OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

    if [ "$OSX_VERS" -lt 9 ]; then
        printf "${RED}Error: bootstrap procedure is not adopted for versions below 10.9${NORMAL}\n"
        exit 1
    fi

    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
}

install_pip_and_ansible() {
    sudo easy_install --quiet pip
    pip install --upgrade setuptools --user python
    sudo pip install -q ansible
}

ansible_galaxy() {
    env ansible-galaxy install -r $source_dir/requirements.yml --force
}

ansible() {
    env ansible-playbook -i "localhost" $source_dir/playbook.yml
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
    
    if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/clang" ]; then
        printf "${BLUE}Installing Command Line Tools...${NORMAL}\n"
        install_command_line_tools
    fi

    install_or_update_bootstrap

    printf "${BLUE}"
    echo '#######################'
    echo 'OSX Bootstrap' $version
    echo '#######################'
    printf "${NORMAL}\n"

    startsudo

    printf "${BLUE}Setting host name to ${host_name}...${NORMAL}\n"
    set_hostname

    printf "\n"

    command -v pip >/dev/null 2>&1 || {
        printf "${BLUE}Installing pip and ansible...${NORMAL}\n"
        install_pip_and_ansible
    }

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
    cowsay 'You may need to restart workstation...'
    echo '#######################'
    printf "${NORMAL}"
}

main
