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
##	QUICK UNINSTALLER
##



INSTALL_DIR="/home/andy" 



##==============================================================================
##	FUNCTIONS
##==============================================================================

uninstallStatus()
{
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/status.sh"



	## REMOVE SCRIPT FILE	
	if [ -f $script ]; then
		rm $script
	fi
	touch "$script"
	chmod 755 "$script"
	

	
	## REMOVE HOOK FROM /etc/bash.bashrc



	## REMOVE CONFIGURATION FILES
}




uninstallFancyBashPrompt()
{
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/fancy-bash-prompt.sh"



	## REMOVE SCRIPT FILE	
	if [ -f $script ]; then
		rm $script
	fi
	touch "$script"
	chmod 755 "$script"
	

	
	## REMOVE HOOK FROM /etc/bash.bashrc



	## REMOVE CONFIGURATION FILES




}





uninstallAll()
{
	uninstallStatus
	uninstallFancyBashPrompt
}




##==============================================================================
##	MAIN
##==============================================================================




if [ $(id -u) -ne 0 ];
	then echo "Please run as root"
	exit
fi



uninstallAll

unset INSTALL_DIR




