#!/bin/sh

## Install basic packages using yaourt. Intended for first-time system setups

# PACKAGES TO INSTALL ----------------------------------------------------------------------

# BASIC SYSADMIN PACKAGES
terminal_packages="rsync atop htop iotop minicom tmux lm_sensors i2c_tools rar unrar 7zip netcat trash-cli ncdu tree nano"

# DESKTOP PACKAGES FOR MOST USERS
desktop_packages="redshift faience-icon-theme owncloud-client gparted nemo nemo-fileroller nemo-preview nemo-share ffmpeg ffmpegthumbnailer gparted gnome-disk-utility autokey-py3"

# WEB BROWSERS AND DOWNLOAD AGENTS
web_packages="firefox chromium flashplugin firefox-i18n-es-es teamspeak3 deluge"

# TEXT AND DOCUMENT PROCESSING TOOLS
office_packages="libreoffice-fresh mousepad gimp calibre kdegraphics-okular inkscape hunspell-en hunspell-es evince acroread acroread-fonts"

# MULTIMEDIA PLAYBACK SOFTARE
multimedia_packages="vlc audacious audacious-plugins smplayer"

# SOFTWARE DEVELOPMENT PACKAGES
development_packages="git gitg qtcreator otf-hack kicad kicad-library kicad-library-3d python python2 guake"




# BE SUDO ----------------------------------------------------------------------------------
sudo -v
# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &




# PERFORMANCE ------------------------------------------------------------------------------
echo "Remmeber to tweak MAKEFLAGS (add -j) in /etc/makepkg.conf"
read -r -p "Do you want to do that now? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	sudo pacman -S --needed --noconfirm nano
	sudo nano /etc/makepkg.conf
fi



# PROMNT USER ------------------------------------------------------------------------------

read -r -p "Install basic sysadmin packages? (Recommended) [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])$ ]];
then
	terminal=false
else
	terminal=true
fi

read -r -p "Install basic desktop packages? (Recommended) [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])$ ]];
then
	desktop=false
else
	desktop=true
fi

read -r -p "Install basic internet, web browser and communications packages? [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])$ ]];
then
	web=false
else
	web=true
fi

read -r -p "Install basic office and image processing packages? [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])$ ]];
then
	office=false
else
	office=true
fi

read -r -p "Install basic multimedia playback packages? [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])$ ]];
then
	multimedia=false
else
	multimedia=true
fi

read -r -p "Install basic development packages? [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])$ ]];
then
	development=false
else
	development=true
fi




# UPDATE SYSTEM ----------------------------------------------------------------------------

sudo pacman -Syu

read -r -p "Update mirrorlist? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	sudo pacman -S --needed --noconfirm reflector
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
	echo "/etc/pacman.d/mirrorlist moved to /etc/pacman.d/mirrorlist.backup"
	echo "Creating new optimized mirrorlist with reflector"
	sudo reflector -l 5 --sort rate --save /etc/pacman.d/mirrorlist
fi 

#update all
sudo pacman -S --needed --noconfirm yaourt
yaourt -Syua --noconfirm




# INSTALL BASIC PACKAGES -------------------------------------------------------------------

if [ "$terminal" = true ]
then
	yaourt -S --noconfirm --needed $terminal_packages
fi

if [ "$desktop" = true ]
then
	yaourt -S --noconfirm --needed $desktop_packages
fi

if [ "$web" = true ]
then
	yaourt -S --noconfirm --needed $web_packages
fi

if [ "$office" = true ]
then
	yaourt -S --noconfirm --needed $office_packages
fi

if [ "$multimedia" = true ]
then
	yaourt -S --noconfirm --needed $multimedia_packages
fi

if [ "$development" = true ]
then
	yaourt -S --noconfirm --needed $development_packages
fi




# TWEAK PACMAN CHACHE ----------------------------------------------------------------------

echo "Clean PACMAN cache for better PACMAN performance in the future."
echo "Answer NO if you think you might want to revert any package back to a previously installed version."
sudo pacman -Sc
sudo pacman-optimize




# EOF

