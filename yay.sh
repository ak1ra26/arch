#!/bin/bash

# Script to install packages on Arch Linux after installing.
# Author: Ak1ra26

# Function to prompt user for confirmation
asksure() {
    read -r -p "Proceed? (Y/N) " answer
    case ${answer:0:1} in
        y|Y )
            echo "Answered Yes"
            XX=0
            ;;
        * )
            echo "Answered No"
            XX=1
            ;;
    esac
}

# Function to check if package is installed using pacman
pacmancheck() {
    if pacman -Qi "$qspackage" > /dev/null 2>&1; then
        echo "The package $qspackage is installed"
        pacmancheckres=1
    else
        echo "The package $qspackage is not installed"
        pacmancheckres=0
    fi
}

# Function to install yay package manager
install_yay() {
    if ! command -v yay >/dev/null 2>&1; then
        echo "Installing yay"
        tmpdir="$(mktemp -d)"
        cd "${tmpdir}" || return 1
        dl_url="$(
            curl -sfLS 'https://api.github.com/repos/Jguer/yay/releases/latest' |
            grep 'browser_download_url' | grep 'x86_64' | cut -d '"' -f 4
        )"
        wget "${dl_url}"
        tar xzvf yay_*_x86_64.tar.gz
        cd yay_*_x86_64 || return 1
        ./yay -Sy yay-bin
        rm -rf "${tmpdir}"
        yay -Syu
    fi
}

# Main function to install packages using yay
install_packages() {
    # Check for yay installation
    install_yay

    # Packages to install
    packages=(
        "google-chrome"
        "slack-desktop"
        "firefox-beta-bin"
        "authy"
        "windscribe-cli"
        "qt5-imageformats"
        "kimageformats"
#        "plasma5-applets-eventcalendar"
        "sni-qt"
        "spotify"
        "perl-image-exiftool"
    )

    # Prompt user for confirmation before installing Virtualbox
    echo "Installing Virtualbox for X11"
    asksure
    if [[ $XX -eq 0 ]]; then
    packages+=("virtualbox" "virtualbox-host-modules-arch" "linux-zen-headers")
    else
            echo "Virtualbox [skipped]"
    fi

    # Prompt user for confirmation before installing plasma5-applets-eventcalendar
    echo "Installing plasma5-applets-eventcalendar"
    asksure
    if [[ $XX -eq 0 ]]; then
    packages+=("go")
    else
            echo "go [skipped]"
            echo "plasma5-applets-eventcalendar [skipped]"
    fi

    # Install packages using yay
    yay --save --answerdiff None --answerclean None --removemake -S "${packages[@]}" --noconfirm --disable-download-timeout

    # Installing plasma5-applets-eventcalendar
    if [[ $XX -eq 0 ]]; then
    git clone https://github.com/kanocz/plasma-applet-eventcalendar eventcalendar # OAuth2 authorization
    # git clone https://github.com/Zren/plasma-applet-eventcalendar.git eventcalendar # original, but without OAuth2
    cd eventcalendar
    sh ./install && rm -rf eventcalendar
    fi
}


# Check if user is not root before running the script
if [[ $(id -u) -eq 0 ]]; then
    echo "This script should not be run as root"
    exit 1
fi

# Install packages
install_packages
