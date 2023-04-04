#!/bin/bash -i
set -uo pipefail # If a variable gets an error the script exits immediately.
trap 'S="${?}" ; echo "${0}" : Error on line "${LINENO}" : "${BASH_COMMAND}" ; exit "${S}"' ERR
#=================# User, hostname and UUID variables. #=================#
URN="alex"					## Username                  ##
yayvbox="";vboxpack="";desktopselect="";
#`lsblk -o PATH,UUID | grep '/dev/sdc1' | awk 'NF>1{print $NF}'`;
#`lsblk -o PATH,UUID | grep '/dev/sdc2' | awk 'NF>1{print $NF}'`;
#========================================================================#
asksure(){
		echo -n " Proceed? (Y/N)"
		while read -r -n 1 -s answer
		do
			if [[ $answer = [YyNn] ]] ; then
			   [[ $answer = [Yy] ]] && echo " Answered Yes " && XX=0 && break
			   [[ $answer = [Nn] ]] && echo " Answered No  " && XX=1 && break
			fi
		done
	clear
}
d_check(){
[ -d "$d_chck" ] && rm -rf $d_chck
}
# sel_gfx_driver(){
# "AMD / ATI (open-source)": "mesa xf86-video-amdgpu xf86-video-ati libva-mesa-driver vulkan-radeon"
# "VMware / VirtualBox (open-source)": "mesa xf86-video-vmware"
# }



key_updater(){
echo "
This step can help with pacman keys problem,
if old ISO ArchLinux is using! "
echo " Update pac-keys?  "
while
read -n1 -p "
1 - nope
0 - yes, this ISO is old " x_key
echo ''
[[ "$x_key" =~ [^10] ]]
do
:
done
if [[ $x_key == 0 ]]; then
pacman-key --refresh-keys
elif [[ $x_key == 1 ]]; then
echo " Key-update is scipped "
fi
}
localtimehost(){
clear
echo 'Please enter your name for machine: '
options=("base" "laptop")
select namechooser in "${options[@]}"
do
    case $namechooser in
        "base")
            HTN="archbase";
            UUID_Data="6f0617e9-3a7e-410d-99d3-3555b525d5a0"
#             UUID_Mega="b94728e9-d898-4cf5-a38d-d778e5edf978"
            clear
            break
            ;;
        "laptop")
            HTN="archlap";
            UUID_Data="3a7c0936-091f-4b51-b869-ec1365758548"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
hwclock --systohc
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo '127.0.0.1  localhost' > /etc/hosts
echo '::1        localhost' >> /etc/hosts
echo "127.0.1.1	 ${HTN}.localdomain ${HTN}" >> /etc/hosts
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
            PACKAGES="partitionmanager onboard vlc songrec neofetch bashtop aspell hunspell-en_us ktouch yt-dlp zenity xdotool xbindkeys xsel xorg-xinput vokoscreen gst-plugins-ugly gst-plugins-bad transmission-qt gwenview ntfs-3g sox steam discord"
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
# Reflector
pacman -S reflector --noconfirm
reflector --verbose --country 'Ukraine,Germany' -l 25 -p https --sort rate  --save /etc/pacman.d/mirrorlist
pacman -Syu --noconfirm

pacman -S --needed $PACKAGES python-pip --noconfirm --disable-download-timeout
# Mega
wget mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
pacman -U megasync-x86_64.pkg.tar.zst --noconfirm
# Google API
pip install google-api-python-client -q
pip install oauth2client -q
#pip3 install telegram-send # for future plans
echo "Pips for work was installed"
}

scrmount(){
#sgdisk -A 2:set:63 /dev/sdb # fix duplicate in fstab file. (nope)
mkdir -p /media/{Data,Share}
if grep --quiet "$UUID_Data" /etc/fstab; then
    echo -en '\n' >> /etc/fstab
    echo "#UUID=$UUID_Data /media/Data               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab #щоб не копіювати якщо щось пішло не так.
    echo Data exists
else
    echo -en '\n' >> /etc/fstab
    echo '# Data' >> /etc/fstab
    echo "UUID=$UUID_Data /media/Data               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab
    mount UUID=$UUID_Data /media/Data
fi
    chown -R ${URN}:wheel /media/Data/
#   chown -R ${URN}:wheel /media/Data/Mega/ # убрати решітку якщо не працює Mega.
    chmod +x -R /media/Data/Mega/sh/*

# if grep --quiet "$UUID_Mega" /etc/fstab; then
#     echo Mega exists
# else
#     echo -en '\n' >> /etc/fstab
#     echo '# Mega' >> /etc/fstab
#     echo "UUID=$UUID_Mega /media/Data/Mega               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab
#     mount UUID=$UUID_Mega /media/Data/Mega
#     chown -R "${URN}":"${URN}" /media/Data/Mega/
#     chmod +x -R /media/Data/Mega/sh/*
# fi
}

aliaslinks(){
if grep "\. /" /home/${URN}/.bashrc | grep --quiet "base.so"; then
    echo "Bash_aliases is ON. Scip";
else
# echo -en '\n' >> /home/${URN}/.bashrc
# echo "# ak1ra26" >> /home/${URN}/.bashrc
# echo "if [ -f /media/Data/Mega/sh/lib/base.so ]; then" >> /home/${URN}/.bashrc
# echo "source /media/Data/Mega/sh/lib/base.so # особиста бібліотека." >> /home/${URN}/.bashrc
# echo "fi" >> /home/${URN}/.bashrc
# echo "Done! You can use ur aliases."
cat <<EOT >> /home/${URN}/.bashrc

# ak1ra26
if [ -f /media/Data/Mega/sh/lib/base.so ]; then
    source /media/Data/Mega/sh/lib/base.so # особиста бібліотека.
fi
Done! You can use ur aliases.
EOT
fi

. /home/${URN}/.bashrc # Turn on .bashrc in this part

d_chck="/home/${URN}/Documents" && d_check
ln -s $Dir_Data/Media/Documents /home/${URN}/Documents
d_chck="/home/${URN}/Videos" && d_check
ln -s $Dir_Data/Media/Videos /home/${URN}/Videos
d_chck="/home/${URN}/Pictures" && d_check
ln -s $Dir_Data/Media/Pictures /home/${URN}/Pictures
d_chck="/home/${URN}/Music" && d_check
ln -s $Dir_Data/Media/Music /home/${URN}/Music
d_chck="/home/${URN}/Downloads" && d_check
ln -s $Dir_Data/Media/Downloads /home/${URN}/Downloads

ln -s $Dir_Mega/sh/config/home_hidden /home/${URN}/.hidden
ln -s $Dir_Mega/sh/config/xbindkeysrc /home/${URN}/.xbindkeysrc
cat $Dir_Data/Media/Documents/Work/Logins | grep "n@remote.q" > /home/${URN}/faststart
echo "" >> /home/${URN}/faststart
cat $Dir_Mega/sh/work/auto_vpn >> /home/${URN}/faststart

ls /home/${URN} -all | grep ".hidden"
ls /home/${URN} -all | grep ".xbindkeysrc"
echo -e "Created ${c_green} .hidden ${c_no} and ${c_green} .xbindkeysrc ${c_no} files"
}

desktopconf(){
clear
echo 'Your desktop is '
options=("KDE" "Sway" "I don't need no educa... desktop")
select desktopselect in "${options[@]}"
do
    case $desktopselect in
        "KDE")
            wget -qO- https://git.io/papirus-icon-theme-install | sh # icons
            git clone https://github.com/ak1ra26/arch
            mv arch /home/${URN}/
#           sed -i -e "s/name=breeze-dark/name=breeze/" "$HOME/.config/plasmarc" && plasmashell --replace
            mkdir -p /home/${URN}/.local/share
            ln -s /home/${URN}/arch/KDE/Dolphin/templates /home/${URN}/.local/share/ # Add templates
            ln -s /home/${URN}/arch/KDE/Applications/Work.desktop /home/${URN}/.local/share/applications/Work.desktop
            ln -s /home/${URN}/arch/KDE/Applications/firefox-beta-bin.desktop /home/${URN}/.local/share/applications/firefox-beta-bin.desktop # change ff-beta's icon
            ln -s /home/${URN}/arch/KDE/Applications/steam.desktop /home/${URN}/.local/share/applications/steam.desktop # change name for steam
            rm -rf /home/${URN}/.config/menus/applications-kmenuedit.menu
            ln -s $Dir_Mega/sh/config/KDE/applications-kmenuedit.menu /home/${URN}/.config/menus/applications-kmenuedit.menu # KDE applications
            rm -rf /home/${URN}/.config/kscreenlockerrc
            ln -s /home/${URN}/arch/KDE/kscreenlockerrc /home/${URN}/.config/kscreenlockerrc # Disable auto-lock
            rm -rf /home/${URN}/.config/kxkbrc
            ln -s /home/${URN}/arch/KDE/kxkbrc /home/${URN}/.config/kxkbrc # Add UA lang
            rm -rf /home/${URN}/.config/khotkeysrc
            ln -s /home/${URN}/arch/KDE/khotkeysrc /home/${URN}/.config/khotkeysrc # Hotkeys
            rm -rf /home/${URN}/.local/share/user-places.xbel
            ln -s /home/${URN}/arch/KDE/Dolphin/user-places.xbel /home/${URN}/.local/share/user-places.xbel # Configure places in Dolphine
            chown ${URN}:wheel -R /home/${URN}/arch/*
            chmod +x /home/${URN}/arch/KDE/Applications/* #потрібно??
            chmod +x /home/${URN}/arch/*
            pacman -S --needed okular ocrdesktop tesseract-data-ukr kwallet-pam fcitx5 fcitx5-gtk fcitx5-qt fcitx5-mozc --noconfirm
            echo "GTK_IM_MODULE=fcitx" >> /etc/environment
            echo "QT_IM_MODULE=fcitx" >> /etc/environment
            echo "XMODIFIERS=@im=fcitx" >> /etc/environment
            break
            ;;
        "Sway")
            pacman -S --needed sway waybar dmenu wget mesa xf86-video-vmware foot mako --noconfirm --disable-download-timeout
#             cp /etc/sway/config ~/.config/sway/
echo "if [ \"$(tty)\" = \"/dev/tty1\" ]; then
exec sway
fi" >> /home/${URN}/.bash_profile
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
#key_updater
localtimehost
pacinst
scrmount
aliaslinks
desktopconf
gitset
} |& tee chroot.log
mv chroot.log /home/"${URN}"/
umount /media/Data
