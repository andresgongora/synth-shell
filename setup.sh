#!/usr/bin/env bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2026, Andres Gongora <mail@andresgongora.com>.     |
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
##  | along with this program. If not, see <https://www.gnu.org/licenses/>. |
##  |                                                                       |
##  +-----------------------------------------------------------------------+

##
##	QUICK INSTALLER
##

##===============================================================================
##	COMMON PATHS AND OPTIONS
##===============================================================================
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -gr ROOT_DIR
declare -gar SCRIPTS=(synth-shell-greeter synth-shell-prompt better-ls alias better-history)

##===============================================================================
##	DEPENDENCIES
##===============================================================================
# shellcheck disable=SC1090
[ "$(type -t include)" != 'function' ] && { include() { { [ -z "$_IR" ] && _IR="$PWD" && cd "$(dirname "${BASH_SOURCE[0]}")" && include "$1" && cd "$_IR" && unset _IR; } || { local d="$PWD" && cd "$(dirname "$PWD/$1")" && . "$(basename "$1")" && cd "$d"; } || { echo "Include failed $PWD->$1" && exit 1; }; }; }

include 'bash-tools/bash-tools/user_io.sh'
include 'bash-tools/bash-tools/shell.sh'
include 'bash-tools/bash-tools/assemble_script.sh'

##===============================================================================
##	HELP
##===============================================================================
printUsage() {
	cat <<EOF
Usage: $0 [OPTION]

Run the interactive installer with no option, or select an operation:
  install                 Install synth-shell system-wide (root required)
  uninstall               Uninstall synth-shell system-wide (root required)
  --build-local [DIR]     Build prompt and greeter into DIR without installing
                          Default: $ROOT_DIR/build/local
  -h, --help              Show this help
EOF
}

##==============================================================================
##	FUNCTIONS
##==============================================================================

## Compose one submodule script and stage its default configuration.
composeComponent() {
	local component="$1"
	local output_script="$2"
	local config_dir="$3"
	local script_header="$4"
	local component_dir="$ROOT_DIR/synth-shell/$component"
	local input_script="$component_dir/$component/$component.sh"
	local config_file="$config_dir/$component.config"
	local default_config="$component_dir/config/$component.config.default"

	# shellcheck disable=SC2034
	local hook_script=False
	if ! assembleScript "$input_script" "$output_script" "$script_header"; then
		[[ -s "$output_script" ]] && bash -n "$output_script" || return 1
	fi
	local normalized_script="${output_script}.normalized"
	awk 'NR == 1 || $0 != "#!/usr/bin/env bash"' "$output_script" >"$normalized_script"
	mv "$normalized_script" "$output_script"
	mkdir -p "$config_dir"
	cp -R "$component_dir/config/." "$config_dir/"
	if [[ ! -f "$config_file" ]]; then
		if [[ "$component" == synth-shell-greeter ]]; then
			local distro
			distro=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
			case "$distro" in
			arch | manjaro | ubuntu | debian | raspbian) default_config="$component_dir/config/os/synth-shell-greeter.$distro.config" ;;
			pop) default_config="$component_dir/config/os/synth-shell-greeter.popos.config" ;;
			esac
		fi
		cp "$default_config" "$config_file"
	fi
}

##------------------------------------------------------------------------------
##
##	INSTALL SCRIPT
##	This function installs a generic script to the system. It copies the
##	script to INSTALL_DIR, and also adds to it all the dependencies from
##	common to make the script completely self contained. Also, this
##	function copies all configuration files to CONFIG_DIR.
##
##	ARGUMENTS
##	1. Name of script. (e.g. "status" or "fancy-bash-prompt")
##
installScript() {
	## ARGUMENTS
	local operation=$1
	local script_name=$2

	## EXTERNAL VARIABLES
	if [ -z "$INSTALL_DIR" ]; then
		echo "INSTALL_DIR not set"
		exit 1
	fi
	if [ -z "$RC_FILE" ]; then
		echo "RC_FILE not set"
		exit 1
	fi
	if [ -z "$CONFIG_DIR" ]; then
		echo "CONFIG_DIR not set"
		exit 1
	fi

	## LOCAL VARIABLES
	local dir="$ROOT_DIR"
	local script="${INSTALL_DIR}/${script_name}.sh"
	local source_script="${dir}/synth-shell/${script_name}.sh"
	local config_template_dir="${dir}/config_templates"
	local edit_text_file_script="$dir/bash-tools/bash-tools/edit_text_file.sh"
	local hook_name="$script_name"
	if [[ "$script_name" == synth-shell-greeter || "$script_name" == synth-shell-prompt ]]; then
		hook_name="${script_name}.sh"
	fi
	# shellcheck disable=SC1090
	source "$edit_text_file_script"

	## TEXT FRAGMENTS
	local hook
	hook=$(printf '%s' \
		"\n" \
		"##-----------------------------------------------------\n" \
		"## ${hook_name}\n" \
		"if [ -f \"${script}\" ] && [ -n \"\$( echo \$- | grep i )\" ]; then\n" \
		"\tsource \"${script}\"\n" \
		"fi")

	local script_header
	script_header=$(printf '%s' \
		"##!/usr/bin/env bash\n" \
		"\n" \
		"##  +-----------------------------------+-----------------------------------+\n" \
		"##  |                                                                       |\n" \
		"##  | Copyright (c) 2014-2026, https://github.com/andresgongora/synth-shell |\n" \
		"##  | Visit the above URL for details of license and authorship.            |\n" \
		"##  |                                                                       |\n" \
		"##  | This program is free software: you can redistribute it and/or modify  |\n" \
		"##  | it under the terms of the GNU General Public License as published by  |\n" \
		"##  | the Free Software Foundation, either version 3 of the License, or     |\n" \
		"##  | (at your option) any later version.                                   |\n" \
		"##  |                                                                       |\n" \
		"##  | This program is distributed in the hope that it will be useful,       |\n" \
		"##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |\n" \
		"##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |\n" \
		"##  | GNU General Public License for more details.                          |\n" \
		"##  |                                                                       |\n" \
		"##  | You should have received a copy of the GNU General Public License     |\n" \
		"##  | along with this program. If not, see <https://www.gnu.org/licenses/>. |\n" \
		"##  |                                                                       |\n" \
		"##  +-----------------------------------------------------------------------+\n" \
		"##\n" \
		"##\n" \
		"##  =======================\n" \
		"##  WARNING!!\n" \
		"##  DO NOT EDIT THIS FILE!!\n" \
		"##  =======================\n" \
		"##\n" \
		"##  This file was generated by an installation script.\n" \
		"##  If you edit this file, it might be overwritten without warning\n" \
		"##  and you will lose all your changes.\n" \
		"##\n" \
		"##  Visit for instructions and more information:\n" \
		"##  https://github.com/andresgongora/synth-shell/\n" \
		"##\n\n\n")

	## INSTALL/UNINSTALL
	case "$operation" in

	uninstall)
		## REMOVE HOOK AND SCRIPT
		printInfo "Removed $script_name hook from $RC_FILE"
		editTextFile "$RC_FILE" delete "$hook"
		if [ -f "$script" ]; then rm "$script"; fi
		;;

	install)

		## CHECK THAT INSTALL DIR EXISTS
		if [ ! -d "$INSTALL_DIR" ]; then
			printInfo "Creating directory $INSTALL_DIR"
			mkdir -p "$INSTALL_DIR"
		fi

		## Build beside the installed script; replace it only after a complete assembly.
		printInfo "Building $script"
		local build_script
		build_script="$(mktemp "${script}.tmp.XXXXXX")"
		printf '%b' "$script_header" >"$build_script"

		if [[ "$script_name" == synth-shell-greeter || "$script_name" == synth-shell-prompt ]]; then
			composeComponent "$script_name" "$build_script" "$CONFIG_DIR" "$script_header" || {
				rm -f "$build_script"
				printError "Could not assemble $script_name"
				return 1
			}

		else
			## ADD CONTENT TO SCRIPT FILE
			## - Add common scripts. TODO: Make this configurable.
			## - Add actual script
			## - Remove common functions from environment
			{
				cat "${dir}/bash-tools/bash-tools/load_config.sh" |
					sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d'
				cat "${dir}/bash-tools/bash-tools/color.sh" |
					sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d'
				cat "${dir}/bash-tools/bash-tools/shorten_path.sh" |
					sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d'
				cat "${dir}/bash-tools/bash-tools/print_utils.sh" |
					sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d'
				cat "$source_script" |
					sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d'
			} >>"$build_script"
			#echo "unset loadConfigFile" >> "$script"
			#echo "unset getFormatCode" >> "$script"

			## COPY CONFIGURATION FILES
			## - Check whether the script has a config file. If so:
			##   - Create the system config folder if none exists
			##   - Check if there is already some configuration in place
			##     - If none, copy current configuration
			##     - If there is, but different, copy with .new extension
			##   - If an example folder exists
			##     - Copy all example files (overwrite old examples)
			local sys_conf_file="${CONFIG_DIR}/${script_name}.config"
			local conf_example_dir="${config_template_dir}/${script_name}.config.examples"
			local conf_template="${config_template_dir}/${script_name}.config"

			if [ -f "$conf_template" ]; then

				printInfo "Adding config files to $CONFIG_DIR"

				if [ ! -d "$CONFIG_DIR" ]; then
					mkdir -p "$CONFIG_DIR"
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

		fi

		chmod 755 "$build_script"
		if ! bash -n "$build_script" || ! mv -f "$build_script" "$script"; then
			rm -f "$build_script"
			printError "Could not install $script_name"
			return 1
		fi
		printInfo "Adding $script_name hook to $RC_FILE"
		editTextFile "$RC_FILE" append "$hook"

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

		printSuccess "Script $script_name successfully installed"

		## EXTRA NOTES DEPENDING ON SCRIPT
		local optional_packages=""
		if [ "$script_name" == "status" ]; then
			local optional_packages="lm_sensors"
		elif [ "$script_name" == "fancy-bash-prompt" ]; then
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

buildLocal() {
	local build_dir="$1"
	local component

	build_dir=$(mkdir -p "$build_dir" && cd "$build_dir" && pwd)
	mkdir -p "$build_dir/home/.config/synth-shell"

	for component in synth-shell-prompt synth-shell-greeter; do
		if ! composeComponent "$component" "$build_dir/$component.sh" \
			"$build_dir/home/.config/synth-shell" ""; then
			return 1
		fi
	done

	printSuccess "Local scripts built in $build_dir"
	printf 'In an interactive Bash, run: source %q\n' "$build_dir/synth-shell-greeter.sh"
	printf 'To test the prompt: source %q\n' "$build_dir/synth-shell-prompt.sh"
}

##------------------------------------------------------------------------------
##
installAll() {
	for script in "${SCRIPTS[@]}"; do
		local action
		action=$(promptUser "Install ${script}? (Y/n)" "" "yYnN" "y")
		case "$action" in
		"" | y | Y)
			installScript install "${script}"
			;;
		*) echo "" ;;
		esac
	done
}

##------------------------------------------------------------------------------
##
uninstallAll() {
	## CHECK IF QUICK-UNINSTALL FILE EXISTS
	local uninstaller="${INSTALL_DIR}/uninstall.sh"
	if [ -f "$uninstaller" ]; then
		## RUN QUICK-UNINSTALLER
		"$uninstaller"
	else
		for script in "${SCRIPTS[@]}"; do
			installScript uninstall "$script"
		done
	fi
}

##==============================================================================
##	MAIN
##==============================================================================

##------------------------------------------------------------------------------
##
installerSystem() {
	local option=$1
	local INSTALL_DIR="/usr/local/bin"
	local CONFIG_DIR="/etc/synth-shell"
	local RC_FILE="/etc/bash.bashrc"

	if [[ $(id -u) -ne 0 ]]; then
		printError "Please run as root"
		exit
	fi

	printInfo "Running systemwide"

	case "$option" in
	uninstall)
		printInfo "Uninstalling synth-shell"
		uninstallAll
		printSuccess "synth-shell was uninstalled"
		;;
	"" | install)
		printInfo "Installing synth-shell"
		installAll
		printSuccess "synth-shell was installed"
		;;
	*)
		echo "Usage: $0 {install|uninstall}" &
		exit 1
		;;
	esac
}

##------------------------------------------------------------------------------
##
installerUser() {
	local option=$1
	local INSTALL_DIR="${HOME}/.config/synth-shell"
	local CONFIG_DIR="${HOME}/.config/synth-shell"
	local user_shell
	user_shell=$(getShellName)

	printInfo "Running for user $USER"

	case "$user_shell" in
	bash) local RC_FILE="${HOME}/.bashrc" ;;
	zsh) local RC_FILE="${HOME}/.zshrc" ;;
	*)
		local RC_FILE="${HOME}/.bashrc"
		printInfo "Could not determine user shell. I will install the scripts into $RC_FILE"
		;;
	esac

	case "$option" in
	uninstall)
		printInfo "Uninstalling synth-shell"
		uninstallAll
		printSuccess "synth-shell was uninstalled"
		;;
	"" | install)
		printInfo "Installing synth-shell"
		installAll
		printSuccess "synth-shell was installed"
		;;
	*)
		echo "Usage: $0 {install|uninstall}" &
		exit 1
		;;
	esac
}

##------------------------------------------------------------------------------
##
##	PROMPT USER FOR INSTALLATION OPTIONS
##
##	USER INSTALL ONLY:	Will add all code to the user's home directory
##	                  	and add hooks to the user's own bashrc file.
##	SYSTEM-WIDE INSTALL:	Will add code to the system and hooks to
##	                    	/etc/bash.bashrc file.
##
installer() {
	if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
		printUsage
	elif [ "${1:-}" = "--build-local" ]; then
		if [ "$#" -gt 2 ]; then
			printf 'Usage: %s --build-local [target-directory]\n' "$0" >&2
			return 2
		fi
		buildLocal "${2:-$ROOT_DIR/build/local}"
	elif [ "$#" -eq 0 ]; then
		printHeader "Installation wizard for synth-shell"

		local action
		action=$(promptUser "Would you like to install or uninstall synth-shell?" "[i] install / [u] uninstall. Default i" "iIuU" "i")
		case "$action" in
		"" | i | I) local install_option="install" ;;
		u | U) local install_option="uninstall" ;;
		*)
			printError "Invalid option"
			exit 1
			;;
		esac

		local action
		action=$(promptUser "Would you like to install it for your current user only (recommended),\n\tor system wide (requires elevated privileges)?" "[u] current user only / [s] system wide install. Default u" "uUsS" "u")
		case "$action" in
		"" | u | U) installerUser $install_option ;;
		s | S) sudo bash "$0" "$install_option" ;;
		*)
			printError "Invalid option"
			exit 1
			;;
		esac

	else
		installerSystem "$1"

	fi
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	installer "$@"
fi
