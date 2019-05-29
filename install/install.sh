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
BASHRC="/etc/bash.bashrc"



##==============================================================================
##	FUNCTIONS
##==============================================================================

##------------------------------------------------------------------------------
##
##	INSTALL SCRIPT
##	This function installs a generic script to the system. It copies the
##	script to INSTALL_DIR, and also adds to it all the dependencies from
##	common to make the script completely self contained. Also, this
##	function copies all configuration files to CONFIG_DIR
##
##	ARGUMENTS
##	1. Name of script. (e.g. "status" or "fancy-bash-prompt")
##
installScript()
{
	script_name=$1	
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/${script_name}.sh"
	local source_script="${dir}/../terminal/${script_name}.sh"



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



	## ADD COMMON SCRIPTS TO FILE
	## TODO: Make this configurable	
	cat "${dir}/../common/load_config.sh" >> "$script"
	echo "" >> ${script}
	cat "${dir}/../common/color.sh" >> "$script"
	echo "" >> ${script}



	## ADD ACTUAL SCRIPT
	cat "$source_script" >> "$script"



	## ADD HOOK TO /etc/bash.bashrc
	## TODO: Only if not already present
	local hook=$(printf '%s'\
	             "##-----------------------------------------------------\n"\
	             "## ${script_name}\n"\
	             "## Added from https://github.com/andresgongora/scripts/\n"\
                     "if [ -f ${script} ]; then\n"\
	             "\tsource ${script}\n"\
                     "fi")

	if [ ! -f "$BASHRC" ]; then
		touch "$BASHRC" || exit 1
	fi
	echo ""         >> $BASHRC
	echo -e "$hook" >> $BASHRC
	echo ""         >> $BASHRC



	## COPY CONFIGURATION FILES
	if [ ! -d $config_dir ]; then
		mkdir -p $config_dir
	fi
	cp -u "${dir}/../config_templates/${script_name}.config" "${CONFIG_DIR}/"
	cp -ur "${dir}/../config_templates/${script_name}.config.examples" "${CONFIG_DIR}/"
}



##------------------------------------------------------------------------------
##
installStatus()
{
	installScript "status"
}



##------------------------------------------------------------------------------
##
installFancyBashPrompt()
{
	installScript "fancy-bash-prompt"
}



##------------------------------------------------------------------------------
##
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
unset BASHRC




