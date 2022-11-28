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

yay -S spotify google-chrome slack-desktop sox windscribe-cli firefox-beta-bin authy $yvbox --noconfirm
}

if [[ `id -u` -ne 0 ]] ; then yayinst ; exit 1 ; fi
echo "Root detected! Abort..."
