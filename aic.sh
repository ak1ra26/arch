#!/bin/bash

echo 'Please enter your choice of config : '
options=("default" "Lenovo T440" "sway")
select optpackages in "${options[@]}"
do
    case $optpackages in
        "default")
            conl="3FqFtQWJ"
            disl=""
            break
            ;;
        "Lenovo T440")
            conl="0Qzyd9BF"
#             disl="--disk_layouts https://pastebin.com/raw/PVAi240a"
            break
            ;;
        "sway")
            conl="g1VMkaeq"
            disl=""
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
curl https://githubusercontent.com/ak1ra26/arch/main/chroot.sh>chroot.sh
chmod +x chroot.sh
archinstall --config https://pastebin.com/raw/$conl #$disl



