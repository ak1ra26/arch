#!/bin/bash

# Script to install packages on Arch Linux after installing.
# Author: Ak1ra26

# Check if user is not root before running the script
if [[ $(id -u) -eq 0 ]]; then
    echo "This script should not be run as root"
    exit 1
fi

# Function to prompt user for confirmation
ask_sure() {
    read -r -p "Proceed? (Y/N) " answer
    [[ "${answer,,}" =~ ^(yes|y)$ ]]
}

dolphinrc=$HOME/.config/dolphinrc; general_lines=("RememberOpenedTabs=false", "ShowSelectionToggle=false", "ShowFullPath=true", "ShowZoomSlider=false")
if ! grep -q "\[ContextMenu\]" "$dolphinrc"; then sed -i '/\[General\]/i [ContextMenu]\nShowAddToPlaces=false\nShowSortBy=false\nShowViewMode=false\n' "$dolphinrc"; fi
for line in "${general_lines[@]}"; do if ! grep -q "$line" "$dolphinrc"; then sed -i "/\[General\]/a $line" "$dolphinrc"; fi; done

# Install yay package manager
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay"
    tmpdir="$(mktemp -d)"
    cd "${tmpdir}" || exit 1
    dl_url="$(curl -sfLS 'https://api.github.com/repos/Jguer/yay/releases/latest' | grep 'browser_download_url' | grep 'x86_64' | cut -d '"' -f 4)"
    wget "${dl_url}"
    tar xzvf yay_*_x86_64.tar.gz
    cd yay_*_x86_64 || exit 1
    ./yay -Sy yay-bin
    rm -rf "${tmpdir}"
    yay -Syu
fi

# Packages to install
packages=(
    "google-chrome"
    "slack-desktop"
    "windscribe-cli"
    "libreoffice-fresh"
    "ttf-google-fonts-git"
)

# Prompt user for confirmation before installing Virtualbox
echo "Installing Virtualbox for X11"
if ask_sure; then
    packages+=("virtualbox" "virtualbox-host-modules-arch" "linux-zen-headers")
else
    echo "Virtualbox [skipped]"
fi

# Prompt user for confirmation before installing plasma5-applets-eventcalendar
echo "Installing plasma5-applets-eventcalendar"
if ask_sure; then
    packages+=("go")
else
    echo "go [skipped]"
    echo "plasma5-applets-eventcalendar [skipped]"
fi

# Install packages using yay
yay --save --answerdiff None --answerclean None --removemake -S "${packages[@]}" --noconfirm --disable-download-timeout

# Installing plasma5-applets-eventcalendar
if [[ "${packages[*]}" =~ "go" ]]; then
    git clone https://github.com/kanocz/plasma-applet-eventcalendar eventcalendar # OAuth2 authorization
    # git clone https://github.com/Zren/plasma-applet-eventcalendar.git eventcalendar # original, but without OAuth2
    sh ./eventcalendar/install && rm -rf eventcalendar
fi

# Function to check if a package is installed using pacman
is_package_installed() {
    pacman -Qi "$1" > /dev/null 2>&1
}

# Check installed packages
echo "Checking installed packages:"
not_installed=()
for package in "${packages[@]}"; do
    if ! is_package_installed "$package"; then
        not_installed+=("$package")
    fi
done

if [ ${#not_installed[@]} -eq 0 ]; then
    echo "All packages were installed successfully."
else
    echo "The following packages were not installed:"
    for package in "${not_installed[@]}"; do
        echo -e "  - \033[31m$package\033[0m"
    done
fi

sudo systemctl enable windscribe.service
