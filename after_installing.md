Settings:

Theme
1. Change theme to Breeze Dark.
2. Set animation speed to more instant
3. Appearance > Global Theme > Window Decorations - set Breeze / set Titlebar Buttons to the left side.
4. Icons > Papirus-Dark
5. Workspace Behavior > Screen Edges - set "No Action".
6. Screen Locking - no lock after | 300 seconds / Recent Files - Keep for 1 month | Do not remember
7. Startup and Shutdown - change SDDM theme | Desktop Session - no confirm & start with empty session

Shortcuts
8. Add my custom shortcuts | Вказати trigger для telegram | Одразу можна тг налаштувати.
9. Додати українську розкладку клавіатури та налаштувати переключення між мовами.

Monitors
10. Set monitors
11. Night Color
12. Turn off micro in Audio
13. Turn off energy saving

Other
14. Turn off search
15. Інколи yay.sh не спрацьовує з першого разу через спотіфай, якщо нема firefox-beta, то ще раз запустити скріпт, але скіпнути Spotify.
16. /media/Mega/sh/config/git.sh запустити
16. Панель вгору перенести, та додати календар (перед цим зробити reboot) | MM月dd日 | HH持mm分ss秒 | Need a fix, waiting <a href="https://github.com/Zren/plasma-applet-eventcalendar/issues/333">archinstall</a>


Доробити:
Додати в shortcuts консоль.
MEGA.nz
Що з авто-git входом?
Firefox не запускається, але якщо спробувати через sudo (не дасть), але після цього запрацює.
Firefox-beta автоматична зміна іконки, щоб не плутатись.
Steam (обрати треба необхідне, уточнити яку опцію саме тре)

Кріпта:
Придумати більш швидкий вхід (декодіровка автоматична тощо, а також сайт для додавання мереж у метамаск підготувати)

sudo mount /dev/sdb1 /mnt
sudo cp -r /mnt/EFI/Microsoft/ /boot/EFI/

sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S steam

#VPN
sudo systemctl start windscribe.service
windscribe account
windscribe login
windscribe connect

#Other
sudo pacman -S libreoffice-fresh
sudo pacman -S unrar
yay -S zoom
yay -S megasync