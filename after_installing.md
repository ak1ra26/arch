Settings:

lookandfeeltool -a org.kde.breezedark.desktop # встановить темну тему.


1. Set animation speed to more instant
# Змінюємо значення параметра AnimationSpeed на 0
sed -i 's/AnimationSpeed=.*/AnimationSpeed=0/g' "$HOME/.config/kwinrc"

# Перезапускаємо KWin
kwin_x11 --replace &

echo "Миттєва швидкість анімації успішно встановлена!"

2. Appearance > Global Theme > Window Decorations > Titlebar Buttons - move it to the left side.
3. Icons > Papirus-Dark
V4. Workspace Behavior > Screen Edges - set "No Action".
5. Startup and Shutdown > Desktop Session - no confirm & start with empty session
# Перевірка наявності файлу ksmserverrc
if [ ! -f "$HOME/.config/ksmserverrc" ]; then
    echo "Помилка: файл ksmserverrc не знайдено"
    exit 1
fi

# знаходження строки confirmLogout та loginMode та заміна їх значень
if grep -q '^\[General\]' ~/.config/ksmserverrc; then
  sed -i '/^\[General\]/a confirmLogout=false\nloginMode=emptySession' ~/.config/ksmserverrc
fi

if grep -q '^offerShutdown=true' ~/.config/ksmserverrc; then
  sed -i 's/^offerShutdown=true/offerShutdown=false/g' ~/.config/ksmserverrc
fi

echo "Налаштування сесії KDE успішно змінено."
6. Add my custom shortcuts | Щоб клавіши зберігалися зробити.
7. Set monitors | Подумати як реалізувати. Я щоб питало чи потрібно.
8. Night Color
9. Configure energy saving
10. Turn off search
# Вимкнути пошук у KDE
kwriteconfig5 --file krunnerrc --group Runners --key enabled false
kwriteconfig5 --file baloorc --group Baloo --key Indexing-Enabled false

echo "Пошук KDE вимкнено."

12. Панель вгору перенести, та додати календар (перед цим зробити reboot) | MM月dd日 | HH持mm分ss秒 | Need a fix, waiting <a href="https://github.com/Zren/plasma-applet-eventcalendar/issues/333">issues/333</a>
<!--# Перевірка наявності файлу з налаштуваннями
if [ ! -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    echo "Помилка: файл plasma-org.kde.plasma.desktop-appletsrc не знайдено"
    exit 1
fi

# Заміна рядків з форматом дати на необхідний | ця хрінь не працює, перевірити!!!
sed -i 's/^dateDisplay=.*/dateDisplay=BesideTime/' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
sed -i 's/^dateFormat=.*/dateFormat=custom/' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
sed -i 's/^customDateFormat=.*/customDateFormat=MM月dd日/' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

echo "Формат дати на панелі KDE успішно змінено"-->

Крипта:
Придумати більш швидкий вхід (декодіровка автоматична тощо, а також сайт для додавання мереж у метамаск підготувати)

#VPN
sudo systemctl enable windscribe.service
windscribe account
windscribe login
windscribe connect

#Other
sudo pacman -S unrar
