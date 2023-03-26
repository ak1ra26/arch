#!/bin/bash

# Get the USB ID of the keyboard
usb_id=$(lsusb | grep "INSTANT USB Keyboard" | awk '{print $6}' | sed 's/^0*//')

# Create a new udev rule to run the script when the keyboard is disconnected
echo 'ACTION=="remove", SUBSYSTEM=="input", ATTRS{idVendor}=="'${usb_id%:*}'", ATTRS{idProduct}=="'${usb_id#*:}'", RUN+="/usr/bin/notify-send USB keyboard disconnected", RUN+="/usr/bin/onboard"' | sudo tee /etc/udev/rules.d/10-usb-keyboard-disconnect.rules

# Reload the udev rules
sudo udevadm control --reload-rules

# Trigger the new rule to take effect
sudo udevadm trigger
