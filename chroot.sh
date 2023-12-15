#!/bin/bash -i
NC='\033[0m'; c_red='\033[0;31m'; c_green='\033[0;32m'

confirm() {
    local prompt="${1:-Proceed?} [${c_green}Y${NC}/${c_red}n${NC}]: "
    echo -en "$prompt"
    read -n 1 choice
    echo -e "\n"  # Перенесення на новий рядок
    case "$choice" in
        y|Y ) return 0;;
        n|N ) return 1;;
        * ) echo "Invalid choice"; return 1;;
    esac
}

inst_chroot() {
# Зчитування змінних зі значеннями за замовчуванням
read -rp "Enter your username [user]: " URN
URN="${URN:-user}"

read -rp "Enter hostname [arch]: " HTN
HTN="${HTN:-arch}"

# Зчитування змінної URP з введення користувача з прихованим виведенням
read -rs -p "Enter your password: " URP
echo "Password entered."

ln -sf /usr/share/zoneinfo/Europe/Kyiv /etc/localtime; hwclock --systohc
echo -e "en_US.UTF-8 UTF-8\nuk_UA.UTF-8 UTF-8" > /etc/locale.gen; locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo ${HTN} > /etc/hostname # Налаштування імені хоста
echo -e "127.0.0.1  localhost\n::1        localhost\n127.0.1.1  ${HTN}.localdomain ${HTN}" > /etc/hosts # Налаштування файлу hosts

useradd -m -G wheel $URN
echo "root:$URP" | chpasswd
echo "$URN:$URP" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers # FIX IT

# Встановлення systemd-boot на EFI розділ
bootctl --path=/boot install

# Налаштування systemd-boot
cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 2
editor 0
EOF

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options root=/dev/sda2 rw
EOF

sed -i 's/^# \[multilib\]/[multilib]/' /etc/pacman.conf
sed -i '/^\[multilib\]$/{n;s/^#//}' /etc/pacman.conf


# Install necessary packages and libraries
PACKAGES="onboard songrec neofetch bashtop aspell hunspell-en_us ktouch yt-dlp zenity xbindkeys vokoscreen gst-plugins-ugly gst-plugins-bad transmission-qt gwenview steam otf-ipafont ffmpeg ffmpegthumbs spectacle firefox code python-pip signal-desktop plasma sddm konsole dolphin kate pulseaudio-alsa alsa-utils networkmanager network-manager-applet dhclient okular kwallet-pam qt5-imageformats kimageformats libheif xdotool"
while ! pacman -S --needed $PACKAGES --noconfirm; do echo "Installation failed. Retrying..."; done
systemctl enable NetworkManager sddm bluetooth

autologin="/etc/sddm.conf.d/autologin.conf"
if [ -f "$autologin" ]; then
  # Файл існує - оновити його з новими значеннями
    sed -i "s/^User=.*$/User=${URN}/" "$autologin"
    sed -i "s/^Session=.*$/Session=plasma/" "$autologin"
else
    echo "[Autologin]" > "$autologin"
    echo "User=${URN}" >> "$autologin"
    echo "Session=plasma" >> "$autologin"
fi

# Install Mega and Google API packages
wget mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
pacman -U megasync-x86_64.pkg.tar.zst --noconfirm
pip install google-api-python-client oauth2client -q
echo "Necessary pip packages and libraries were installed"

echo 'Please select your device:: '
declare -A options=([PC]='archbase 6f0617e9-3a7e-410d-99d3-3555b525d5a0' [laptop]='archlap 3a7c0936-091f-4b51-b869-ec1365758548')
select namechooser in "${!options[@]}"; do
if [[ -n ${options[$namechooser]} ]]; then
    read -r HTN UUID_Data <<<"${options[$namechooser]}"
    clear
    break
else
    echo "invalid option $REPLY"
fi
done

mkdir -p /media/{Data,Share}
if grep --quiet "$UUID_Data" /etc/fstab; then
    echo Data exists
else
    echo -e "\n# Data\nUUID=$UUID_Data /media/Data               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab
    mount UUID=$UUID_Data /media/Data
fi

if grep "\. /" /home/${URN}/.bashrc | grep --quiet "lib.so"; then
    echo "Bash_aliases is ON. Skip";
else
cat > /home/${URN}/.bashrc << 'EOF'
[[ $- != *i* ]] && return # If not running interactively, don't do anything
if [ -f /media/Data/Projects/Github/lib/lib.so ]; then
source /media/Data/Projects/Github/lib/lib.so # особиста бібліотека.
fi
EOF
fi

chown -R $URN:$URN /media/Data/
. /home/${URN}/.bashrc # Turn on .bashrc in this part
find $Dir_Data/Projects/ -type f -iname "*.sh" -exec chmod +x {} \;

# Function to check if a package is installed using pacman
is_package_installed() {
    pacman -Qi "$1" > /dev/null 2>&1
}

# Check installed packages
echo "Checking installed packages:"
not_installed=()
for package in "${PACKAGES[@]}"; do
    if ! is_package_installed "$package"; then
        not_installed+=("$package")
    fi
done

if [ ${#not_installed[@]} -eq 0 ]; then
    echo "All packages were installed successfully."
else
    echo "The following packages were not installed:" > /home/${URN}/not_installed.log
    for package in "${not_installed[@]}"; do
        echo -e "  - \033[31m$package\033[0m" >> > /home/${URN}/not_installed.log
    done
fi

dolphinrc=~/.config/dolphinrc; general_lines=("RememberOpenedTabs=false", "ShowSelectionToggle=false", "ShowFullPath=true", "ShowZoomSlider=false")
if ! grep -q "\[ContextMenu\]" "$dolphinrc"; then sed -i '/\[General\]/i [ContextMenu]\nShowAddToPlaces=false\nShowSortBy=false\nShowViewMode=false\n' "$dolphinrc"; fi
for line in "${general_lines[@]}"; do if ! grep -q "$line" "$dolphinrc"; then sed -i "/\[General\]/a $line" "$dolphinrc"; fi; done

test -e $Dir_Data/Media/Documents && OK || { echo "Can't find Dir_Data"; . /home/${URN}/.bashrc; find $Dir_Data/Projects/ -type f -iname "*.sh" -exec chmod +x {} \;}
ln -sfv $Dir_Data/Media/Documents /home/${URN}/Documents
ln -sfv $Dir_Data/Media/Videos /home/${URN}/Videos
ln -sfv $Dir_Data/Media/Pictures /home/${URN}/Pictures
ln -sfv $Dir_Data/Media/Music /home/${URN}/Music
ln -sfv $Dir_Data/Media/Downloads /home/${URN}/Downloads

ln -sfv $Dir_Data/Projects/Github/arch/KDE/home_hidden /home/${URN}/.hidden
ln -sfv $Dir_Data/Projects/Github/arch/KDE/xbindkeysrc /home/${URN}/.xbindkeysrc
cat $Dir_Data/Media/Documents/Work/Logins | grep "n@remote.q" > /home/${URN}/faststart
echo "" >> /home/${URN}/faststart
cat $Dir_Data/Media/Documents/Work/auto_vpn >> /home/${URN}/faststart

sudo pacman -S papirus-icon-theme
mkdir -p /home/alex/.local/share/applications
mkdir -p /home/alex/.config/menus/
ln -sfv $Dir_Data/Projects/Github/arch/KDE/dolphin/templates /home/${URN}/.local/share/ # Add templates
ln -sfv $Dir_Data/Projects/Github/arch/KDE/applications/Work.desktop /home/${URN}/.local/share/applications/Work.desktop
ln -sfv $Dir_Data/Projects/Github/arch/KDE/applications/firefox-beta-bin.desktop /home/${URN}/.local/share/applications/firefox-beta-bin.desktop # change ff-beta's icon
ln -sfv $Dir_Data/Projects/Github/arch/KDE/applications/steam.desktop /home/${URN}/.local/share/applications/steam.desktop # change name for steam
# ln -sfv $Dir_Data/Projects/Github/arch/KDE/applications-kmenuedit.menu /home/${URN}/.config/menus/applications-kmenuedit.menu # KDE applications
ln -sfv $Dir_Data/Projects/Github/arch/KDE/kscreenlockerrc /home/${URN}/.config/kscreenlockerrc # Disable auto-lock
ln -sfv $Dir_Data/Projects/Github/arch/KDE/kxkbrc /home/${URN}/.config/kxkbrc # Add UA lang
ln -sfv $Dir_Data/Projects/Github/arch/KDE/khotkeysrc /home/${URN}/.config/khotkeysrc # Hotkeys
ln -sfv $Dir_Data/Projects/Github/arch/KDE/dolphin/user-places.xbel /home/${URN}/.local/share/user-places.xbel # Configure places in Dolphine

# Installation and configuration of VLC
pacman -S --needed vlc --noconfirm
cvlc --reset-config vlc://quit # Launch VLC to generate the configuration file.
sed -i '/^#\{0,1\}qt-privacy-ask=/s/.*/qt-privacy-ask=0/' /home/${URN}/.config/vlc/vlcrc # Disable network policy prompt at startup
sed -i '/^#\{0,1\}metadata-network-access=/s/.*/metadata-network-access=0/' /home/${URN}/.config/vlc/vlcrc # Disable metadata network access
sed -i '/^#\{0,1\}aout=/s/.*/aout=alsa/' /home/${URN}/.config/vlc/vlcrc # Resolve audio stuttering after pausing/resuming playback
sed -i '/^#\{0,1\}qt-continue=/s/.*/qt-continue=2/' /home/${URN}/.config/vlc/vlcrc # Enable continuous playback.

# Виход з chroot
exit
}

{
inst_chroot
echo ; echo " Script log available, run 'less inst_chroot.log'"
} |& tee inst_chroot.log
