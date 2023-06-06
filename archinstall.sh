#!/bin/bash

NC='\033[0m'
c_red='\033[0;31m'
c_green='\033[0;32m'

confirm() {
  local prompt="${1:-Proceed?} [${c_green}Y${NC}/${c_red}n${NC}]: "
  echo -en "$prompt"
  read -n 1 choice
  case "$choice" in
    y|Y ) return 0;;
    n|N ) return 1;;
    * ) echo "Invalid choice"; return 1;;
  esac
}

# Зчитування змінних зі значеннями за замовчуванням
read -rp "Enter your username [alex]: " URN
URN="${URN:-alex}"

read -rp "Enter hostname [archbase]: " HTN
HTN="${HTN:-archbase}"

# Зчитування змінної URP з введення користувача з прихованим виведенням
read -rs -p "Enter your password: " URP
echo "Password entered."

echo "This step can help resolve issues with Pacman keys, in case an old ArchLinux ISO is being used."
confirm "Update pacman keys?" && pacman-key --refresh-keys || echo "Key update skipped."

# Задаємо правильний системний час
timedatectl set-ntp true

# Отримання списку доступних дисків
disks=$(lsblk -dplnx size -o name | grep -Ev "boot|rpmb|loop")

# Перевірка, чи є доступні диски
if [ -z "$disks" ]; then
  echo "No disks found."
  exit 1
fi

# Виведення списку дисків і питання користувачу про вибір
echo "Available disks:"; lsblk | grep -Ev "rpmb|loop"
read -rp "Enter the disk to use (e.g., sda, sdb, nvme0n1): " disk

# Перевірка, чи введено дійсний диск
if ! echo "$disks" | grep -qw "$disk"; then
  echo "Invalid disk selected."
  exit 1
fi

confirm "Use disk ${disk}?" || { echo "Exit"; exit 1; }

# Створення нового розділу GPT
parted /dev/$disk mklabel gpt

# Створення розділу EFI
parted /dev/$disk mkpart primary fat32 1MiB 513MiB
parted /dev/$disk set 1 boot on

# Створення розділу для кореневої файлової системи
parted /dev/$disk mkpart primary ext4 513MiB 100%

# Форматування розділів
mkfs.fat -F32 /dev/${disk}1
mkfs.ext4 /dev/${disk}2

# Монтування розділів
mount /dev/${disk}2 /mnt
mkdir /mnt/boot
mount /dev/${disk}1 /mnt/boot

# Update mirrorlist
reflector --verbose --country 'Ukraine,Germany' -l 25 -p https --sort rate  --save /etc/pacman.d/mirrorlist

pacman -Syu --noconfirm

# Встановлення базової системи
pacstrap /mnt base base-devel linux-zen linux-firmware intel-ucode nano vim reflector bash-completion git curl

# Налаштування файлу fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Зміна кореневого каталогу
arch-chroot /mnt

# Налаштування часової зони
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime; hwclock --systohc

# Налаштування необхідних локалей та мови системи
echo -e "en_US.UTF-8 UTF-8\nuk_UA.UTF-8 UTF-8" > /etc/locale.gen; locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Налаштування імені хоста
echo ${HTN} > /etc/hostname

# Налаштування файлу hosts
echo -e "127.0.0.1  localhost\n::1        localhost\n127.0.1.1  ${HTN}.localdomain ${HTN}" > /etc/hosts

# Налаштування пароля для користувача root
echo "root:$URP" | chpasswd

# Створення нового користувача та надання йому прав адміністратора
useradd -m -G wheel $URN
echo "$URN:$URP" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Встановлення загрузчика Systemd-boot
pacman -S --noconfirm systemd-boot

# Встановлення systemd-boot на EFI розділ
bootctl --path=/boot install

# Налаштування systemd-boot
cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 3
editor 0
EOF

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF

echo 'Please enter your choice of packages: '
options=("default" "wayland test")
select optpackages in "${options[@]}"
do
    case $optpackages in
        "default")
            PACKAGES="xf86-video-intel onboard haruna songrec neofetch bashtop aspell hunspell-en_us ktouch yt-dlp zenity xbindkeys vokoscreen gst-plugins-ugly gst-plugins-bad transmission-qt gwenview steam otf-ipafont ffmpeg ffmpegthumbs spectacle firefox code python-pip telegram-desktop plasma sddm konsole kate pulseaudio-alsa networkmanager network-manager-applet dhclient okular kwallet-pam qt5-imageformats kimageformats libheif"
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

# Install necessary packages and libraries
pacman -S --needed $PACKAGES --noconfirm --disable-download-timeout

systemctl enable NetworkManager
systemctl enable sddm
# sudo pacman -S bluez bluez-utils bluedevil pulseaudio-bluetoot
# systemctl enable bluetooth.service

# Install Mega and Google API packages
wget mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
pacman -U megasync-x86_64.pkg.tar.zst --noconfirm
pip install google-api-python-client -q
pip install oauth2client -q
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
cat > /home/${URN}/.bashrc <<EOF
# ak1ra26
[[ $- != *i* ]] && return # If not running interactively, don't do anything
if [ -f /media/Data/Projects/Github/lib/lib.so ]; then
source /media/Data/Projects/Github/lib/lib.so # особиста бібліотека.
fi
EOF
fi

. /home/${URN}/.bashrc # Turn on .bashrc in this part

chown -R $URN:$URN /media/Data/
find $Dir_Mega/sh/ -type f -iname "*.sh" -exec chmod +x {} \;
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
    echo "The following packages were not installed:"
    for package in "${not_installed[@]}"; do
        echo -e "  - \033[31m$package\033[0m"
    done
fi

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
cat $Dir_Data/Media/Documents/Work/auto_vpn >> /home/${URN}/faststart

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

curl https://raw.githubusercontent.com/ak1ra26/arch/main/yay.sh>/home/$URN/yay.sh; chmod +x /home/$URN/yay.sh

# Виход з chroot та розмонтовування розділів
exit
umount -R /mnt

# Повідомлення про завершення установки
echo "Установка Arch Linux завершена. Видаліть установочний носій і перезавантажте систему."




