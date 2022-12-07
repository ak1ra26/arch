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
            UUID_Mega="b94728e9-d898-4cf5-a38d-d778e5edf978"
            clear
            break
            ;;
        "laptop")
            HTN="archlap";
            UUID_Data="###"
            UUID_Mega="###"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
#echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
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
options=("default" "wayland test" "fast for work")
select optpackages in "${options[@]}"
do
    case $optpackages in
        "default")
            PACKAGES="vlc songrec neofetch bashtop aspell hunspell-en_us ktouch yt-dlp zenity xdotool xbindkeys xsel xorg-xinput vokoscreen gst-plugins-ugly gst-plugins-bad transmission-qt gwenview ntfs-3g sox steam discord"
            clear
            break
            ;;
        "wayland test")
            PACKAGES="wayland xorg-xwayland"
            break
            ;;
        "fast for work")
            PACKAGES="vlc zenity xdotool xbindkeys xsel xorg-xinput gwenview"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

clear
pacman -Syu --noconfirm --disable-download-timeout
pacman -S --needed $PACKAGES python-pip --noconfirm --disable-download-timeout
# Google API
pip install google-api-python-client -q
pip install oauth2client -q
#pip3 install telegram-send # for future plans
echo "Pips for work was installed"
}

scrmount(){
#sgdisk -A 2:set:63 /dev/sdb # fix duplicate in fstab file. (nope)
mkdir -p /media/{Data,Mega}
if grep --quiet "$UUID_Data" /etc/fstab; then
    echo Data exists
else
    echo -en '\n' >> /etc/fstab
    echo '# Data' >> /etc/fstab
    echo "UUID=$UUID_Data /media/Data               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab
    mount UUID=$UUID_Data /media/Data
    chown -R "${URN}":"${URN}" /media/Data/
fi

if grep --quiet "$UUID_Mega" /etc/fstab; then
    echo Mega exists
else
    echo -en '\n' >> /etc/fstab
    echo '# Mega' >> /etc/fstab
    echo "UUID=$UUID_Mega /media/Mega               ext4    errors=remount-ro,auto,user,rw,exec 0       0" >> /etc/fstab
    mount UUID=$UUID_Mega /media/Mega
    chown -R "${URN}":"${URN}" /media/Mega/
    chmod +x -R /media/Mega/sh/*
fi
}

aliaslinks(){
if grep "\. /" /home/${URN}/.bashrc | grep --quiet "bash_aliases"; then
    echo "Bash_aliases is ON. Scip";
else
echo -en '\n' >> /home/${URN}/.bashrc
echo "# ak1ra26" >> /home/${URN}/.bashrc
echo "if [ -f /media/Mega/sh/config/bash_aliases ]; then" >> /home/${URN}/.bashrc
echo ". /media/Mega/sh/config/bash_aliases" >> /home/${URN}/.bashrc
echo "fi" >> /home/${URN}/.bashrc
echo "Done! You can use ur aliases."
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
ln -s $Dir_Mega/sh/kismia/work.sh /home/${URN}/work.sh
cat $Dir_Data/Media/Doc*/Ki*/Logins | grep "n@r" > /home/${URN}/faststart
echo "" >> /home/${URN}/faststart
cat $Dir_Mega/sh/kismia/auto_vpn >> /home/${URN}/faststart

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
            git clone https://github.com/ak1ra26/KDE
            rm -rf KDE/.git
            mkdir -p /home/"${URN}"/.local/share
            mv KDE/templates /home/"${URN}"/.local/share/
            mv KDE /home/"${URN}"/
            chown "${URN}":wheel -R /home/"${URN}"/*
            chmod +x /home/"${URN}"/.local/share/templates/source/script
            chown "${URN}":wheel -R /home/"${URN}"/.local # fix unable to save bookmarks in /home/$USER/.local/share/user-places.xbel error.
            wget -qO- https://git.io/papirus-icon-theme-install | sh # icons
            echo "" >> /home/${URN}/faststart
            echo "/media/Mega/sh/kismia/work.sh" >> /home/${URN}/faststart
            pacman -S --needed partitionmanager --noconfirm --disable-download-timeout
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
git clone https://github.com/ak1ra26/arch
mv arch /home/"${URN}"/
chown "${URN}":wheel -R /home/"${URN}"/arch
sh $Dir_Mega/sh/config/git
echo ; echo "Exit then reboot!";
}

testthis(){
echo "[Desktop Entry]
Comment=
Exec=/media/Mega/sh/kismia/work.sh
Icon=among-us
Name=Work
NoDisplay=false
Path=
StartupNotify=false
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
" > /home/${URN}/.local/share/applications/Work.desktop

cp -r /media/Mega/sh/config/shortcuts /home/${URN}/.config/khotkeysrc # hotkeys
cp -r /media/Mega/sh/config/kxkbrc /home/${URN}/.config/kxkbrc # ua_lang adder
#wallp inside plasma-org.kde.plasma.desktop-appletsrc

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
#testthis
} |& tee chroot.log
mv chroot.log /home/"${URN}"/
umount /media/Mega
umount /media/Data
