##!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019, Andres Gongora <mail@andresgongora.com>.          |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+

##
##	QUICK INSTALLER
##
##	This script will install these scripts to /usr/bin/locale and will
##	apply status.sh and fancy-bash-prompt.sh systemwide.
##	THIS IS WORK IN PROGRESS
##

installAll()
{
	## CHECK IF GIT IS PRESET
	local gitbin=$(which git)
	if [ -z $gitbin ]; then
		echo "Git is not installed"
		exit 1 
	fi


	## GET ADMIN RIGHTS AND GO TO INSTALL FOLDER
	sudo -v
	cd /usr/local/bin


	## DOWNLOAD SCRIPTS
	if [ -d ./scripts ]; then
		sudo rm -r ./scripts
	fi
	sudo 'git' clone --recursive --branch features/installer -n --depth 1 https://github.com/andresgongora/scripts.git
	chmod -R 


	## INSTALL ANCHOR
	sudo su root -c 'printf "## Added by https://github.com/andresgongora/scripts.git\n if [ -f /usr/local/bin/scripts/install/anchor.sh ]; then\n\tsource /usr/local/bin/scripts/install/anchor.sh\nfi" >> /etc/bash.bashrc'
}

installAll

