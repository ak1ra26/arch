Settings:

1. Change theme to Breeze Dark. #lookandfeeltool -a org.kde.breezedark.desktop перевірити, бо не все замінює.
2. Set animation speed to more instant
3. Appearance > Global Theme > Window Decorations - set Breeze / set Titlebar Buttons to the left side.
4. Icons > Papirus-Dark
5. Workspace Behavior > Screen Edges - set "No Action".
6. Screen Locking - no lock after | 300 seconds / Recent Files - Keep for 1 month | Do not remember #/home/username/.config/kscreenlockerrc
7. Startup and Shutdown - change SDDM theme | Desktop Session - no confirm & start with empty session
8. Add my custom shortcuts | Вказати trigger для telegram | Одразу можна тг налаштувати.
9. Додати українську розкладку клавіатури та налаштувати переключення між мовами.
10. Set monitors
11. Night Color
12. Turn off micro in Audio
13. Turn off energy saving
14. Turn off search
15. /media/Data/Mega/sh/config/git.sh запустити
16. Панель вгору перенести, та додати календар (перед цим зробити reboot) | MM月dd日 | HH持mm分ss秒 | Need a fix, waiting <a href="https://github.com/Zren/plasma-applet-eventcalendar/issues/333">issues/333</a>


Доробити:
Додати в shortcuts консоль.
MEGA.nz
Що з авто-git входом?
Firefox не запускається, але якщо спробувати через sudo (не дасть), то після цього запрацює.
Firefox-beta автоматична зміна іконки, щоб не плутатись. /usr/share/applications/ or here https://unix.stackexchange.com/questions/256593/how-do-i-change-the-icon-for-an-application-on-the-kde-panel

Кріпта:
Придумати більш швидкий вхід (декодіровка автоматична тощо, а також сайт для додавання мереж у метамаск підготувати)

sudo mount /dev/sdb1 /mnt
sudo cp -r /mnt/EFI/Microsoft/ /boot/EFI/

#VPN
sudo systemctl start windscribe.service
windscribe account
windscribe login
windscribe connect

#Other
sudo pacman -S libreoffice-fresh
sudo pacman -S unrar
yay -S zoom
