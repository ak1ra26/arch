#!/bin/bash
# Check if cronie is installed and install it if necessary
if ! command -v crontab &> /dev/null; then
  echo "cronie is not installed. Installing..."
  sudo pacman -S cronie
fi

# Set the path to the script
script_path="/media/Data/Mega/sh/work/otipo.sh"

# Add the script to the crontab
echo "*/1 * * * * bash $script_path" | crontab -

# Display the updated crontab
crontab -l
