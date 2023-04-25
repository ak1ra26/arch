#!/bin/bash -i
set -uo pipefail # If a variable gets an error the script exits immediately.
trap 'S="${?}" ; echo "${0}" : Error on line "${LINENO}" : "${BASH_COMMAND}" ; exit "${S}"' ERR

URN="alex";yayvbox="";vboxpack="";desktopselect="";

asksure() {
    while true; do
        read -r -n 1 -p "Proceed? (Y/N) " answer
        case $answer in
            [Yy]* ) echo " Answered Yes"; XX=0; break;;
            [Nn]* ) echo " Answered No"; XX=1; break;;
            * ) echo "Please answer Yes or No.";;
        esac
    done
    clear
}

key_updater(){
    echo "This step can help resolve issues with Pacman keys, in case an old ArchLinux ISO is being used."
    asksure && [[ $XX == 0 ]] && pacman-key --refresh-keys || echo " Key-update is skipped "
}

localtimehost() {
    clear
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

    echo -e "en_US.UTF-8 UTF-8\nuk_UA.UTF-8 UTF-8" > /etc/locale.gen; locale-gen
    ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime; hwclock --systohc
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo -e "127.0.0.1  localhost\n::1        localhost\n127.0.1.1  ${HTN}.localdomain ${HTN}" > /etc/hosts
    echo "${HTN}" > /etc/hostname
}

pacinst(){
clear
echo 'Please enter your choice of packages: '
options=("default" "wayland test")
select optpackages in "${options[@]}"
do
    case $optpackages in
        "default")
            PACKAGES="partitionmanager onboard vlc songrec neofetch bashtop aspell hunspell-en_us ktouch yt-dlp zenity xbindkeys xorg-xinput vokoscreen gst-plugins-ugly gst-plugins-bad transmission-qt gwenview steam xorg-xwininfo"
            clear
            break
            ;;
        "wayland test")
            PACKAGES="wayland xorg-xwayland"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

clear
# Install reflector and update mirrorlist
pacman -S reflector --noconfirm
reflector --verbose --country 'Ukraine,Germany' -l 25 -p https --sort rate  --save /etc/pacman.d/mirrorlist
pacman -Syyu --noconfirm
# Install necessary packages and libraries
pacman -S --needed $PACKAGES python-pip --noconfirm --disable-download-timeout
# Install Mega and Google API packages
wget mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
pacman -U megasync-x86_64.pkg.tar.zst --noconfirm
pip install google-api-python-client -q
pip install oauth2client -q
echo "Necessary packages and libraries were installed"
}

scrmount(){
mkdir -p /media/{Data,Share}
if grep --quiet "$UUID_Data" /etc/fstab; then
    echo Data exists
else
    echo -e "\n# Data\nUUID=$UUID_Data /media/Data               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab
    mount UUID=$UUID_Data /media/Data
fi
}

aliaslinks(){
if grep "\. /" /home/${URN}/.bashrc | grep --quiet "base.so"; then
    echo "Bash_aliases is ON. Skip";
else
cat > /home/${URN}/.bashrc <<EOF
# ak1ra26
[[ \$- != *i* ]] && return # If not running interactively, don't do anything
if [ -f /media/Data/Mega/sh/lib/base.so ]; then
    source /media/Data/Mega/sh/lib/base.so # Personal library.
fi
EOF
fi

. /home/${URN}/.bashrc # Turn on .bashrc in this part

chown -R $URN:$URN /media/Data/
find $Dir_Mega/sh/ -type f -iname "*.sh" -exec chmod +x {} \;
find $Dir_Data/Projects/ -type f -iname "*.sh" -exec chmod +x {} \;

d_check(){
[ -d "$d_chck" ] && rm -rf $d_chck
}
d_chck="/home/${URN}/Documents" && d_check
ln -sv $Dir_Data/Media/Documents /home/${URN}/Documents
d_chck="/home/${URN}/Videos" && d_check
ln -sv $Dir_Data/Media/Videos /home/${URN}/Videos
d_chck="/home/${URN}/Pictures" && d_check
ln -sv $Dir_Data/Media/Pictures /home/${URN}/Pictures
d_chck="/home/${URN}/Music" && d_check
ln -sv $Dir_Data/Media/Music /home/${URN}/Music
d_chck="/home/${URN}/Downloads" && d_check
ln -sv $Dir_Data/Media/Downloads /home/${URN}/Downloads

ln -sv $Dir_Mega/sh/config/home_hidden /home/${URN}/.hidden
ln -sv $Dir_Mega/sh/config/xbindkeysrc /home/${URN}/.xbindkeysrc
cat $Dir_Data/Media/Documents/Work/Logins | grep "n@remote.q" > /home/${URN}/faststart
echo "" >> /home/${URN}/faststart
cat $Dir_Mega/sh/work/auto_vpn >> /home/${URN}/faststart
}

desktopconf(){
clear
systemctl enable bluetooth.service
echo 'Your desktop is '
options=("KDE" "I don't need no educa... desktop")
select desktopselect in "${options[@]}"
do
    case $desktopselect in
    "KDE")
        wget -qO- https://git.io/papirus-icon-theme-install | sh # icons
        mkdir -p /home/${URN}/.local/share
        ln -sv $Dir_Data/Projects/Github/arch/KDE/Dolphin/templates /home/${URN}/.local/share/ # Add templates
        ln -sv $Dir_Data/Projects/Github/arch/KDE/Applications/Work.desktop /home/${URN}/.local/share/applications/Work.desktop
        ln -sv $Dir_Data/Projects/Github/arch/KDE/Applications/firefox-beta-bin.desktop /home/${URN}/.local/share/applications/firefox-beta-bin.desktop # change ff-beta's icon
        ln -sv $Dir_Data/Projects/Github/arch/KDE/Applications/steam.desktop /home/${URN}/.local/share/applications/steam.desktop # change name for steam
        rm -rf /home/${URN}/.config/menus/applications-kmenuedit.menu
        ln -sv $Dir_Mega/sh/config/KDE/applications-kmenuedit.menu /home/${URN}/.config/menus/applications-kmenuedit.menu # KDE applications
        rm -rf /home/${URN}/.config/kscreenlockerrc
        ln -sv $Dir_Data/Projects/Github/arch/KDE/kscreenlockerrc /home/${URN}/.config/kscreenlockerrc # Disable auto-lock
        rm -rf /home/${URN}/.config/kxkbrc
        ln -sv $Dir_Data/Projects/Github/arch/KDE/kxkbrc /home/${URN}/.config/kxkbrc # Add UA lang
        rm -rf /home/${URN}/.config/khotkeysrc
        ln -sv $Dir_Data/Projects/Github/arch/KDE/khotkeysrc /home/${URN}/.config/khotkeysrc # Hotkeys
        rm -rf /home/${URN}/.local/share/user-places.xbel
        ln -sv $Dir_Data/Projects/Github/arch/KDE/Dolphin/user-places.xbel /home/${URN}/.local/share/user-places.xbel # Configure places in Dolphine
        read -p "Do you want to install fcitx? (Y/N) " -r answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            pacman -S --needed fcitx5 fcitx5-gtk fcitx5-qt fcitx5-mozc --noconfirm
            echo -e "GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx" >> /etc/environment
            mkdir -p /home/${URN}/.config/fcitx5 && ln -sf $Dir_Data/Projects/Github/arch/IM/fcitx/profile /home/${URN}/.config/fcitx5/profile
        fi
        # Install additional packages for KDE
        pacman -S --needed okular kwallet-pam qt5-imageformats kimageformats --noconfirm
        break
        ;;
    "I don't need no educa... desktop")
        break
        ;;
    *) echo "invalid option $REPLY";;
    esac
done
}

gitset(){
sh $Dir_Mega/sh/config/git
echo ; echo "Exit then reboot!";
}

# Group bracket below for logging #
{
key_updater
localtimehost
pacinst
scrmount
aliaslinks
desktopconf
gitset
} |& tee chroot.log
mv chroot.log /home/"${URN}"/
umount /media/Data
