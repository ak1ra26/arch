#!/bin/bash

echo 'Please enter your choice of config (don\'t use sway option for now) : '
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
            conl="g1VMkaeq"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
#done
archinstall --config https://pastebin.com/raw/$conl



