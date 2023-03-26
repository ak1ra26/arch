Settings:

1. Set animation speed to more instant
# Знаходимо шлях до файлу kwinrc
KWINRC_PATH=$(find ~/.config -name kwinrc)

# Зберігаємо резервну копію файлу kwinrc
cp "$KWINRC_PATH" "$KWINRC_PATH.bak"

# Змінюємо значення параметра AnimationSpeed на 0
sed -i 's/AnimationSpeed=.*/AnimationSpeed=0/g' "$KWINRC_PATH"

# Перезапускаємо KWin
kwin_x11 --replace &

echo "Миттєва швидкість анімації успішно встановлена!"

2. Appearance > Global Theme > Window Decorations > Titlebar Buttons - move it to the left side.
3. Icons > Papirus-Dark
# Install Papirus-Dark icon theme
sudo pacman -S papirus-icon-theme

# Set Papirus-Dark as default icon theme
echo "XDG_CURRENT_DESKTOP=KDE" >> ~/.xprofile
echo "export XDG_CURRENT_DESKTOP" >> ~/.xprofile
echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ~/.xprofile
echo "export QT_QPA_PLATFORMTHEME" >> ~/.xprofile
echo "QT_STYLE_OVERRIDE=papirus-dark" >> ~/.config/environment.d/qt5ct.conf

# Reload environment variables
source ~/.xprofile

Цей скрипт встановлює пакунок papirus-icon-theme з репозиторію Arch Linux, який містить Papirus-Dark тему іконок. Після встановлення теми, скрипт встановлює її як тему іконок за замовчуванням для середовища KDE.

Для цього скрипт додає змінну XDG_CURRENT_DESKTOP до файлу ~/.xprofile, щоб вказати, що використовується середовище KDE, а потім додає змінні QT_QPA_PLATFORMTHEME і QT_STYLE_OVERRIDE до файла ~/.config/environment.d/qt5ct.conf, щоб вказати середовищу KDE використовувати qt5ct як платформу для налаштування стилю, а також papirus-dark як тему іконок за замовчуванням.

Нарешті, скрипт перезавантажує змінні середовища, щоб вони були доступні після наступного входу в систему.


4. Workspace Behavior > Screen Edges - set "No Action".
# Перевірка наявності файлу kwinrc
if [ ! -f "$HOME/.config/kwinrc" ]; then
    echo "Помилка: файл kwinrc не знайдено"
    exit 1
fi

# Find the line number of the [ElectricBorders] group
line=$(grep -n "\[ElectricBorders\]" ~/.config/kwinrc | cut -d ":" -f 1)

# Find the line number of the next group
next_line=$(tail -n +$((line+1)) ~/.config/kwinrc | grep -n "\[" | head -n 1 | cut -d ":" -f 1)
if [ -z "$next_line" ]; then
    next_line=$(wc -l < ~/.config/kwinrc)
else
    next_line=$((line+next_line-1))
fi

# Remove the [ElectricBorders] group and everything until the next group
sed -i "$line,${next_line}d" ~/.config/kwinrc
echo "Налаштування країв екрану успішно змінено."

5. Startup and Shutdown > Desktop Session - no confirm & start with empty session
# Перевірка наявності файлу ksmserverrc
if [ ! -f "$HOME/.config/ksmserverrc" ]; then
    echo "Помилка: файл ksmserverrc не знайдено"
    exit 1
fi

# знаходження строки confirmLogout та loginMode та заміна їх значень
sed -i '/^\[General\]/a confirmLogout=false\nloginMode=emptySession' ~/.config/ksmserverrc
sed -i 's/^offerShutdown=true/offerShutdown=false/g' ~/.config/ksmserverrc

echo "Налаштування сесії KDE успішно змінено."
6. Add my custom shortcuts | Вказати trigger для telegram | Одразу можна тг налаштувати.
7. Set monitors
8. Night Color
9. Configure energy saving
10. Turn off search
# Вимкнути пошук у KDE
kwriteconfig5 --file krunnerrc --group Runners --key enabled false
kwriteconfig5 --file baloorc --group Baloo --key Indexing-Enabled false

echo "Пошук KDE вимкнено."

11. /media/Data/Mega/sh/config/git.sh запустити
12. Панель вгору перенести, та додати календар (перед цим зробити reboot) | MM月dd日 | HH持mm分ss秒 | Need a fix, waiting <a href="https://github.com/Zren/plasma-applet-eventcalendar/issues/333">issues/333</a>
<!--# Перевірка наявності файлу з налаштуваннями
if [ ! -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    echo "Помилка: файл plasma-org.kde.plasma.desktop-appletsrc не знайдено"
    exit 1
fi

# Заміна рядків з форматом дати на необхідний
sed -i 's/^dateDisplay=.*/dateDisplay=BesideTime/' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
sed -i 's/^dateFormat=.*/dateFormat=custom/' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
sed -i 's/^customDateFormat=.*/customDateFormat=MM月dd日/' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

echo "Формат дати на панелі KDE успішно змінено"-->


Доробити:
Що з авто-git входом?

Крипта:
Придумати більш швидкий вхід (декодіровка автоматична тощо, а також сайт для додавання мереж у метамаск підготувати)

#Хуїта (можливо колись знадобиться)
sudo mount /dev/sdb1 /mnt
sudo cp -r /mnt/EFI/Microsoft/ /boot/EFI/

#VPN
sudo systemctl start windscribe.service
windscribe account
windscribe login
windscribe connect

#Other
sudo pacman -S libreoffice-fresh unrar
