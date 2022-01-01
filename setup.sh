#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2021, Andres Gongora <mail@andresgongora.com>.     |
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



##==============================================================================
##	DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd $(dirname "${BASH_SOURCE[0]}")&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d=$PWD&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}

include 'bash-tools/bash-tools/user_io.sh'
include 'bash-tools/bash-tools/shell.sh'






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
	## ARGUMENTS
	local operation=$1
	local script_name=$2



	## EXTERNAL VARIABLES
	if [ -z $INSTALL_DIR ]; then echo "INSTALL_DIR not set"; exit 1; fi
	if [ -z $RC_FILE ];     then echo "RC_FILE not set";     exit 1; fi
	if [ -z $CONFIG_DIR ];  then echo "CONFIG_DIR not set";  exit 1; fi



	## LOCAL VARIABLES
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/${script_name}.sh"
	local source_script="${dir}/synth-shell/${script_name}.sh"
	local config_template_dir="${dir}/config_templates"
	local uninstaller="${INSTALL_DIR}/uninstall.sh"
	local edit_text_file_script="$dir/bash-tools/bash-tools/edit_text_file.sh"
	source "$edit_text_file_script"



	## TEXT FRAGMENTS
	local hook=$(printf '%s'\
	"\n"\
	"##-----------------------------------------------------\n"\
	"## ${script_name}\n"\
	"if [ -f ${script} ] && [ -n \"\$( echo \$- | grep i )\" ]; then\n"\
	"\tsource ${script}\n"\
	"fi")



	local script_header=$(printf '%s'\
	"##!/bin/bash\n"\
	"\n"\
	"##  +-----------------------------------+-----------------------------------+\n"\
	"##  |                                                                       |\n"\
	"##  | Copyright (c) 2014-2021, https://github.com/andresgongora/synth-shell |\n"\
	"##  | Visit the above URL for details of license and authorship.            |\n"\
	"##  |                                                                       |\n"\
	"##  | This program is free software: you can redistribute it and/or modify  |\n"\
	"##  | it under the terms of the GNU General Public License as published by  |\n"\
	"##  | the Free Software Foundation, either version 3 of the License, or     |\n"\
	"##  | (at your option) any later version.                                   |\n"\
	"##  |                                                                       |\n"\
	"##  | This program is distributed in the hope that it will be useful,       |\n"\
	"##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |\n"\
	"##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |\n"\
	"##  | GNU General Public License for more details.                          |\n"\
	"##  |                                                                       |\n"\
	"##  | You should have received a copy of the GNU General Public License     |\n"\
	"##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |\n"\
	"##  |                                                                       |\n"\
	"##  +-----------------------------------------------------------------------+\n"\
	"##\n"\
	"##\n"\
	"##  =======================\n"\
	"##  WARNING!!\n"\
	"##  DO NOT EDIT THIS FILE!!\n"\
	"##  =======================\n"\
	"##\n"\
	"##  This file was generated by an installation script.\n"\
	"##  If you edit this file, it might be overwritten without warning\n"\
	"##  and you will lose all your changes.\n"\
	"##\n"\
	"##  Visit for instructions and more information:\n"\
	"##  https://github.com/andresgongora/synth-shell/\n"\
	"##\n\n\n")



	## INSTALL/UNINSTALL
	case "$operation" in

	uninstall)
		## REMOVE HOOK AND SCRIPT
		printInfo "Removed $script_name hook from $RC_FILE"
		editTextFile "$RC_FILE" delete "$hook"
		if [ -f $script ]; then rm $script; fi
		;;


	install)

		## CHECK THAT INSTALL DIR EXISTS
		if [ ! -d $INSTALL_DIR ]; then
			printInfo "Creating directory $INSTALL_DIR"
			mkdir -p $INSTALL_DIR
		fi



		## CREATE EMPTY SCRIPT FILE
		printInfo "Creating file $script"
		if [ -f $script ]; then
			rm $script
		fi
		touch "$script" || exit 1
		chmod 755 "$script"
		echo -e "${script_header}" >> ${script}


		## WARNING!! UGLY PATCH, WORK IN PROGRESS
		if [ "$script_name" == "synth-shell-greeter" ]; then
			printInfo "Installing as $script"
			"${dir}/synth-shell/synth-shell-greeter/setup.sh" "$script" "$CONFIG_DIR"

		elif [ "$script_name" == "synth-shell-prompt" ]; then
			printInfo "Installing as $script"
			"${dir}/synth-shell/synth-shell-prompt/setup.sh" "$script" "$CONFIG_DIR"


		else
			## ADD CONTENT TO SCRIPT FILE
			## - Add common scripts TODO: Make this configurable
			## - Add actual script
			## - Remove common functions from environment
			cat "${dir}/bash-tools/bash-tools/load_config.sh" |\
				sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
			cat "${dir}/bash-tools/bash-tools/color.sh" |\
				sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
			cat "${dir}/bash-tools/bash-tools/shorten_path.sh" |\
				sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
			cat "${dir}/bash-tools/bash-tools/print_utils.sh" |\
				sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
			cat "$source_script" |\
				sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
			#echo "unset loadConfigFile" >> "$script"
			#echo "unset getFormatCode" >> "$script"



			## COPY CONFIGURATION FILES
			## - Check if script has config file at all. If so:
			##   - Create system config folder if there is none
			##   - Check if there is already some configuration in place
			##     - If none, copy current configuration
			##     - If there is, but different, copy with .new extension
			##   - If example folder exists
			##     - Copy all examples files (overwrite old examples)
			local sys_conf_file="${CONFIG_DIR}/${script_name}.config"
			local conf_example_dir="${config_template_dir}/${script_name}.config.examples"
			local conf_template="${config_template_dir}/${script_name}.config"

			if [ -f $conf_template ]; then

				printInfo "Adding config files to $CONFIG_DIR"

				if [ ! -d $CONFIG_DIR ]; then
					mkdir -p $CONFIG_DIR
				fi

				if [ ! -f "$sys_conf_file" ]; then
					cp -u "${conf_template}" "${sys_conf_file}"
				#elif ( ! cmp -s "$conf_template" "$sys_conf_file" ); then
				#	cp -u "${conf_template}" "${sys_conf_file}.new"
				#	printWarn "Old configuration file detected"
				#	printInfo "New file written to ${sys_conf_file}.new"
				fi

				if [ -d "$conf_example_dir" ]; then
					printInfo "Adding example config files to ${CONFIG_DIR}"
					cp -ur "$conf_example_dir" "${CONFIG_DIR}/"
				fi

			fi

			## ADD HOOK TO /etc/bash.bashrc
			printInfo "Adding $script_name hook to $RC_FILE"
			editTextFile "$RC_FILE" append "$hook"
		fi



		## ADD QUICK-UNINSTALLER
		## TODO: FIX
		#printInfo "Adding quick uninstaller as $uninstaller"
		#editTextFile "$uninstaller" append "$script_header"
		#cat "$edit_text_file_script" |\
		#	sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$uninstaller"
		#editTextFile "$uninstaller" append "rm -rf ${CONFIG_DIR}"
		#echo "hook=\"$hook\"" >> "$uninstaller"
		#echo "editTextFile \"$RC_FILE\" delete \"\$hook\"" >> "$uninstaller"
		#echo "unset hook" >> "$uninstaller"
		#chmod +x "$uninstaller"



		printSuccess "Script $script_name succesfully installed"



		## EXTRA NOTES DEPENDING ON SCRIPT
		local optional_packages=""
		if [ $script_name == "status" ]; then
			local optional_packages="lm_sensors"
		elif [ $script_name == "fancy-bash-prompt" ]; then
			local optional_packages="powerline-fonts"
		fi

		if [ -n "$optional_packages" ]; then
			printInfo "Consider installing the following packages as well."
			printInfo "The exact name might change between distributions:"
			printText "$optional_packages"
		fi



		## Print final separator
		echo ""



		;;



	*)
		echo $"Usage: $0 {install|uninstall}"
            	exit 1
		;;

	esac
}



##------------------------------------------------------------------------------
##
installAll()
{
	for script in $SCRIPTS; do
		local action=$(promptUser "Install ${script}? (Y/n)" "" "yYnN" "y")
		case "$action" in
			""|y|Y )	installScript install "${script}"
					;;
			*)		echo ""
		esac
	done
}



##------------------------------------------------------------------------------
##
uninstallAll()
{
	## CHECK IF QUICK-UNINSTALL FILE EXISTS
	local uninstaller="${INSTALL_DIR}/uninstall.sh"
	if [ -f "$uninstaller" ]; then
		## RUN QUICK-UNINSTALLER
		"$uninstaller"
	else
		for script in $SCRIPTS; do
			installScript uninstall "$script"
		done
	fi
}



##==============================================================================
##	MAIN
##==============================================================================

##------------------------------------------------------------------------------
##
installerSystem()
{
	local option=$1
	local INSTALL_DIR="/usr/local/bin"
	local CONFIG_DIR="/etc/synth-shell"
	local RC_FILE="/etc/bash.bashrc"

	if [ $(id -u) -ne 0 ]; then
		printError "Please run as root"
		exit
	fi

	printInfo "Running systemwide"

	case "$option" in
		uninstall)	printInfo "Uninstalling synth-shell"
				uninstallAll
				printSuccess "synth-shell was uninstalled"
				;;
		""|install)	printInfo "Installing synth-shell"
				installAll
				printSuccess "synth-shell was installed"
				;;
		*)		echo "Usage: $0 {install|uninstall}" & exit 1
	esac
}




##------------------------------------------------------------------------------
##
installerUser()
{
	local option=$1
	local INSTALL_DIR="${HOME}/.config/synth-shell"
	local CONFIG_DIR="${HOME}/.config/synth-shell"
	local user_shell=$(getShellName)


	printInfo "Running for user $USER"


	case "$user_shell" in
		bash)		local RC_FILE="${HOME}/.bashrc" ;;
		zsh)		local RC_FILE="${HOME}/.zshrc" ;;
		*)		local RC_FILE="${HOME}/.bashrc"
				printInfo "Could not determine user shell. I will install the scripts into $RC_FILE"
	esac


	case "$option" in
		uninstall)	printInfo "Uninstalling synth-shell"
				uninstallAll
				printSuccess "synth-shell was uninstalled"
				;;
		""|install)	printInfo "Installing synth-shell"
				installAll
				printSuccess "synth-shell was installed"
				;;
		*)		echo "Usage: $0 {install|uninstall}" & exit 1
	esac
}





##------------------------------------------------------------------------------
##
##	PROMPT USER FOR INSTALLATION OPTIONS
##
##	USER INSTALL ONLY:	Will all code to user's home dir
##	                  	and add hooks to its own bashrc file.
##	SYSTEM WIDE INSTALL:	Will add code to system and hooks to
##	                    	/etc/bash.bashrc file.
##
installer()
{
	local SCRIPTS="
		synth-shell-greeter
		synth-shell-prompt
		better-ls
		alias
		better-history
		"

	if [ "$#" -eq 0 ]; then
		printHeader "Installation wizard for synth-shell"

		local action=$(promptUser "Would you like to install or uninstall synth-shell?" "[i] install / [u] uninstall. Default i" "iIuU" "i")
		case "$action" in
			""|i|I )	local install_option="install" ;;
			u|U )		local install_option="uninstall" ;;
			*)		printError "Invalid option"; exit 1
		esac


		local action=$(promptUser "Would you like to install it for your current user only (recommended),\n\tor system wide (requires elevated privileges)?" "[u] current user only / [s] system wide install. Default u" "uUsS" "u")
		case "$action" in
			""|u|U )	installerUser $install_option ;;
			s|S )		sudo bash -c "bash $0 $install_option" ;;
			*)		printError "Invalid option"; exit 1
		esac

	else
		installerSystem $1

	fi
}

installer "$@"
