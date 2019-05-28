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



INSTALL_DIR="/usr/local/bin" 
CONFIG_DIR="/etc/andresgongora/scripts"



##==============================================================================
##	FUNCTIONS
##==============================================================================

installStatus()
{
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/status.sh"
	



	## CREATE EMPTY SCRIPT FILE	
	if [ -f $script ]; then
		rm $script
	fi
	touch "$script" || exit 1
	chmod 755 "$script"
	

	
	echo "##!/bin/bash" >> ${script}
	echo "##Created by https://github.com/andresgongora/scripts" >> ${script}
	echo "##Do NOT modify manually" >> ${script}
	echo "" >> ${script}
		

		
	## ADD SCRIPT DEPENDENCIES TO FILE	
	cat "${dir}/../common/load_config.sh" >> "$script"
	echo "" >> ${script}
	cat "${dir}/../common/color.sh" >> "$script"
	echo "" >> ${script}



	## ADD ACTUAL SCRIPT
	cat "${dir}/../terminal/status.sh" >> "$script"



	## ADD HOOK TO /etc/bash.bashrc
	echo ""  >>  /etc/bash.bashrc
	echo "## Added by: https://github.com/andresgongora/scripts/" >>  /etc/bash.bashrc
	echo "if [ -f ${script} ]; then" >>  /etc/bash.bashrc
	echo "	/usr/local/bin/scripts/terminal/status.sh" >>  /etc/bash.bashrc
	echo "fi" >>  /etc/bash.bashrc
	echo ""  >>  /etc/bash.bashrc



	## COPY CONFIGURATION FILES
	if [ ! -d $config_dir ]; then
		mkdir -p $config_dir
	fi
	cp -u "${dir}/../config_templates/status.config" "${CONFIG_DIR}/"
	cp -ur "${dir}/../config_templates/status.config.examples" "${CONFIG_DIR}/"
}




installFancyBashPrompt()
{
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/fancy-bash-prompt.sh"



	## CREATE EMPTY SCRIPT FILE	
	if [ -f $script ]; then
		rm $script
	fi
	touch "$script" || exit 1
	chmod 644 "$script"
	

	
	echo "##!/bin/bash" >> ${script}
	echo "##Created by https://github.com/andresgongora/scripts" >> ${script}
	echo "##Do NOT modify manually" >> ${script}
	echo "" >> ${script}
		

		
	## ADD SCRIPT DEPENDENCIES TO FILE	
	cat "${dir}/../common/load_config.sh" >> "$script"
	echo "" >> ${script}
	cat "${dir}/../common/color.sh" >> "$script"
	echo "" >> ${script}



	## ADD ACTUAL SCRIPT
	cat "${dir}/../terminal/fancy-bash-prompt.sh" >> "$script"



	## ADD HOOK TO /etc/bash.bashrc
	echo ""  >>  /etc/bash.bashrc
	echo "## Added by: https://github.com/andresgongora/scripts/" >>  /etc/bash.bashrc
	echo "if [ -f ${script} ]; then" >>  /etc/bash.bashrc
	echo "	source ${script}" >>  /etc/bash.bashrc
	echo "fi" >>  /etc/bash.bashrc
	echo ""  >>  /etc/bash.bashrc



	## COPY CONFIGURATION FILES
	if [ ! -d $config_dir ]; then
		mkdir -p $config_dir
	fi
	cp -u "${dir}/../config_templates/fancy-bash-prompt.config" "${CONFIG_DIR}/"
	cp -ur "${dir}/../config_templates/fancy-bash-prompt.config.examples" "${CONFIG_DIR}/"
}





installAll()
{
	installStatus
	installFancyBashPrompt
}




##==============================================================================
##	MAIN
##==============================================================================




if [ $(id -u) -ne 0 ];
	then echo "Please run as root"
	exit
fi



installAll

unset INSTALL_DIR
unset CONFIG_DIR




