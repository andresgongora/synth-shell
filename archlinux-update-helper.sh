#!/bin/sh

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	|                        ARCHLINUX UPDATE HELPER                        |
##	|                                                                       |
##	| Copyright (c) 2017, Andres Gongora <mail@andresgongora.com>.          |
##	|                                                                       |
##	| This program is free software: you can redistribute it and/or modify  |
##	| it under the terms of the GNU General Public License as published by  |
##	| the Free Software Foundation, either version 3 of the License, or     |
##	| (at your option) any later version.                                   |
##	|                                                                       |
##	| This program is distributed in the hope that it will be useful,       |
##	| but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##	| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##	| GNU General Public License for more details.                          |
##	|                                                                       |
##	| You should have received a copy of the GNU General Public License     |
##	| along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##	|                                                                       |
##	+-----------------------------------------------------------------------+


##
##	This script performs the following operations:
##		1. Update mirrolist for maximum speed 
##		2. Update pacman & create log
##		3. Optimize pacman
##	
##	This script requires super-user privileges	
## 


################################################################################
##	FUNCTIONS                                                             ##
################################################################################


################################################################################
## ECHO HELPERS (Inspired by Zach Holman)

printHeader ()
{
	printf "\n\n\r	\033[1;37m$1\n"
}

printInfo ()
{
	printf "\r	[ \033[00;34m..\033[0m ] $1\n"
}

printPromt ()
{
	printf "\r	[ \033[0;33m??\033[0m ] $1"
}

printSuccess ()
{
	printf "\r\033[2K	[ \033[00;32mOK\033[0m ] $1\n"
}


printWarn ()
{
	printf "\r\033[2K	[ \033[00;33m!!\033[0m ] $1\n"
}

printFail ()
{
	printf "\r\033[2K	[\033[0;31mFAIL\033[0m] $1\n"
	echo ''
	exit
}



################################################################################
## UPDATE MIRROLIST FOR MAXIMUM SPEED 

updateMirrorlist ()
{
	printHeader "Optimizing mirrorlist..."
	
	
	printInfo "Checking if reflector is installed"
	if [ -f /usr/bin/reflector ]; then 
		printSuccess "Reflector already installed"
	
	else 
	 	printInfo "Reflector not installed. Installing:\n"
	 	sudo pacman -Sy reflector --noconfirm --color=auto
	 	echo ""
	 	if [ -f /usr/bin/reflector ]; then 
	 		printSuccess "Reflector successfully installed"
	 	else
	 		printFail "Could not install reflector"
	 	fi
	fi
	
	
	printInfo "Creating backup mirrorlist"
	MIRRORLIST=/etc/pacman.d/mirrorlist
	BACKUP=/etc/pacman.d/mirrorlist.backup
	if [ -f $BACKUP ]; then 
		sudo rm $BACKUP # remove old backup if it exists
	fi
	sudo cp $MIRRORLIST $BACKUP
	if [ -f $BACKUP ]; then 
		printSuccess "Mirrorlist backed up to $BACKUP"
	else
		printFail "Could not backup current mirrorlist to $BACKUP"
	fi
	
	
	printInfo "Optimizing mirrorlist for maximum download speed:\n"
	sudo reflector -l 5 --verbose --sort rate --save /etc/pacman.d/mirrorlist
	echo ""
	printInfo "Refreshing package list:\n"
	sudo pacman -Syy --color=auto
	echo ""
	printSuccess "Mirrorlist updated and packages refreshed"
	
	
}


################################################################################
## UPDATE SYSTEM

updateSystem ()
{
	printHeader "Updating system..."
	
	
	printInfo "Downloading new packages"
	sudo pacman -Suwq --noconfirm --color=auto
	echo""
	
	
	LOGFILE=~/pacman.log
	printInfo "A brief pacman log will be stored at $LOGFILE"
	printInfo "Updating system:\n"
	sudo pacman -Su --noconfirm | tee $LOGFILE
	echo ""	
	

	printSuccess "System updated"
}



################################################################################
## OPTIMIZE PACMAN

optimizePacman ()
{
	local prunechace=
	local action=
	local THISTTY=$(tty)
	

	printHeader "Optimizing pacman..."
	
	
	printInfo "Removing orphan packages from the system"
	printInfo "If it complains about no targets, it means that you have no orphans:\n"
	sudo pacman -Rns --noconfirm --color=auto $(pacman -Qtdq)
	echo ""
	
	
	printPromt "Remove old packages from cache? (Not recommended) y/N: "
	exec 6<&0
	exec 0<"$THISTTY"
	read -n 1 action
	exec 0<&6 6<&-

	case "$action" in
		y )
			prunechace=true;;
		Y )
			prunechace=true;;
		* )
			prunechace=false;;
	esac
	
	if [ "$prunechace" == "true" ]; then
		printInfo "Removing uninstalled packages:\n"
		sudo pacman -Sc --noconfirm --color=auto
		echo ""
	else
		printInfo "... skipping"
	fi
	
	
	printInfo "Compacting pacman database for faster access in the future:\n"
	sudo pacman-optimize
	
	
	printSuccess "Pacman optimized"	
}




################################################################################
##	MAIN                                                                  ##
################################################################################

## GREET MESSAGE
printHeader "ARCHLINUX SYSTEM-UPDATE HELPER"
printWarn "I will use super-user privileges...\n"


## GET SU PRIVILEGES
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


## RUN SCRIPT
updateMirrorlist
updateSystem
optimizePacman


## GOODBY MESSAGE
printHeader "SUCCESS! SYSTEM UPDATED AND OPTIMIZED"
printWarn "But remmember to check the logs to see if you have to:"
printWarn " >>  Replace old config files with .pacnew files"
printWarn " >>  Act on any alert or warning"
printWarn "If needed, you may find a more extensive log at /var/log/pacman.log"
printWarn "Reference: https://wiki.archlinux.org/index.php/System_maintenance"
echo "\n"


### EOF ###
