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

pacmancheck(){
if pacman -Qi $qspackage > /dev/null ; then
  echo "The package $qspackage is installed"
  pacmancheckres=1
else
  echo "The package $qspackage is not installed"
  pacmancheckres=0
fi
}

yayinst(){
if ! builtin type -p 'yay' >/dev/null 2>&1; then
    echo 'Install yay:'
    tmpdir="$(command mktemp -d)"
    command cd "${tmpdir}" || return 1
    dl_url="$(
        command curl -sfLS 'https://api.github.com/repos/Jguer/yay/releases/latest' |
        command grep 'browser_download_url' | grep 'x86_64' | cut -d '"' -f 4
    )"
    command wget "${dl_url}"
    command tar xzvf yay_*_x86_64.tar.gz
    command cd yay_*_x86_64 || return 1
    ./yay -Sy yay-bin
    echo "$tmpdir" #for test
    echo "$dl_url" #for test
    rm -rf "${tmpdir}"
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

yay -S google-chrome slack-desktop firefox-beta-bin authy windscribe-cli megasync plasma5-applets-eventcalendar $yvbox --noconfirm --disable-download-timeout
yay -S spotify --noconfirm --disable-download-timeout

# Це фікс помилки при встановленні Spotify because they release a new pkg with a different commit number and a different checksum. Дякую Joan31 за підказку. Але треба перевірити, бо писав цей код у блокноті на зміні, коли мене відволікали. Треба _commit=gc5f8b819 замінити на _commit=gc5f8b819-2, а 3cc25f28ae791ac26607117a5df668f803ed8e58f0ace085010a6242fdde97766bdc1c752560850795c9b4324f3e019937fe9af2788a1946ebb70ee781f50d99 на 9ba6c2d155f683b9a38222d58a2a53a2a5f4b422ed1c0d603af87919ba8a68309aea3354278fd1d5d8142a1568d93b7e83b14c041e749b0c39f3bc155a633ef8, щоб Spotify встановився.
qspackage=spotify && pacmancheck
if	[[ $pacmancheckres = 0 ]]; then
yay -G spotify && cd spotify
sed -i 's/_commit=gc5f8b819/_commit=gc5f8b819-2/g;s/3cc25f28ae791ac26607117a5df668f803ed8e58f0ace085010a6242fdde97766bdc1c752560850795c9b4324f3e019937fe9af2788a1946ebb70ee781f50d99/9ba6c2d155f683b9a38222d58a2a53a2a5f4b422ed1c0d603af87919ba8a68309aea3354278fd1d5d8142a1568d93b7e83b14c041e749b0c39f3bc155a633ef8/g' PKGBUILD
makepkg -si
cd .. && rm -fr spotify
fi
#dark_theme KDE
lookandfeeltool -a org.kde.breezedark.desktop
}

if [[ `id -u` -ne 0 ]] ; then yayinst ; exit 1 ; fi
echo "Root detected! Abort..."
