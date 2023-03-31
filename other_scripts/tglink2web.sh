#!/bin/bash
# This script opens telegram's link in Firefox, not in Telegram.
tglink=$(echo $1 | sed 's|tg://resolve?domain=||g')

xdotool key Ctrl+w;
firefox "https://web.telegram.org/?legacy=1#/im?p=@"$tglink
exit
