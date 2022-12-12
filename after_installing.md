Settings:

1. Set animation speed to more instant
2. Appearance > Global Theme > Window Decorations > Titlebar Buttons - move it to the left side.
3. Icons > Papirus-Dark
4. Workspace Behavior > Screen Edges - set "No Action".
5. Startup and Shutdown > Desktop Session - no confirm & start with empty session
6. Add my custom shortcuts | Вказати trigger для telegram | Одразу можна тг налаштувати.
7. Set monitors
8. Night Color
9. Configure energy saving
10. Turn off search
11. /media/Data/Mega/sh/config/git.sh запустити
12. Панель вгору перенести, та додати календар (перед цим зробити reboot) | MM月dd日 | HH持mm分ss秒 | Need a fix, waiting <a href="https://github.com/Zren/plasma-applet-eventcalendar/issues/333">issues/333</a>


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
