#!/bin/bash
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

yayinst(){
if ! builtin type -p 'yay' >/dev/null 2>&1; then
    echo "Installing yay"
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
    yay -Syu
fi

clear
echo; echo " Installing Virtualbox for X11"
asksure
if	[[ $XX = 0 ]]; then
if ! builtin type -p 'yay' >/dev/null 2>&1; then
echo "No yay. Virtualbox-ext-oracle [skipped]"
else
yvbox="virtualbox-ext-oracle linux-zen-headers"
fi
else
yvbox=""
fi

yay -S spotify google-chrome slack-desktop windscribe-cli $yvbox --noconfirm
}

if [[ `id -u` -ne 0 ]] ; then yayinst ; exit 1 ; fi
echo "Root detected! Abort..."
