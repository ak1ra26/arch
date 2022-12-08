#!/bin/bash

echo 'Please enter your choice of config : '
options=("default" "Lenovo T440" "sway")
select optpackages in "${options[@]}"
do
    case $optpackages in
        "default")
            conl="3FqFtQWJ"
            break
            ;;
        "Lenovo T440")
            conl="0Qzyd9BF"
            break
            ;;
        "sway")
            conl="g1VMkaeq --disk_layouts https://pastebin.com/raw/PVAi240a"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
archinstall --config https://pastebin.com/raw/$conl



