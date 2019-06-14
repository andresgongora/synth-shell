#!/bin/bash

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	| Copyright (c) 2018-2019, Andres Gongora <mail@andresgongora.com>.     |
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
##	DESCRIPTION
##
##	This script updates your "PS1" environment variable to display colors.
##	Additionally, it also shortens the name of your current path to a maximum
##	25 characters, which is quite useful when working in deeply nested folders.
##
##
##
##	REFFERENCES
##
##	* http://tldp.org/HOWTO/Bash-Prompt-HOWTO/index.html
##
##



fancy_bash_prompt()
{



##==============================================================================
##	FUNCTIONS
##==============================================================================


##------------------------------------------------------------------------------
##	getGitBranch
##	Returns current git branch for current directory, if and only if,
##	the current directory is part of a git repository, and git is installed.
##	Returns an empty string otherwise.
##
getGitBranch()
{
	if ( which git > /dev/null 2>&1 ); then
		git branch 2> /dev/null | sed -n '/^[^*]/d;s/*\s*\(.*\)/\1/p'
	else
		echo ""
	fi
}






##------------------------------------------------------------------------------
##
printSegment()
{
	## GET PARAMETERS
	local text=$1
	local font_color=$2
	local background_color=$3
	local next_background_color=$4
	local font_effect=$5
	if [ -z "$separator_char" ]; then echo "separator_char is blank"; local separator_char="X"; fi



	## COMPUTE COLOR FORMAT CODES
	local no_color="\[$(getFormatCode -e reset)\]"
	local text_format="\[$(getFormatCode -c $font_color -b $background_color -e $font_effect)\]"
	local separator_format="\[$(getFormatCode -c $background_color -b $next_background_color)\]"



	## GENERATE TEXT
	printf "${text_format}${text}${separator_format}${separator_char}${no_color}"
}






##------------------------------------------------------------------------------
##
prompt_command_hook()
{
	## LOAD EXTERNAL DEPENENCIES
	## Only if the functions are not available
	## If not, search in `common` folder
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	if [ "$(type -t shortenPath)" != 'function' ];
	then
		source "$dir/../common/shorten_path.sh"
	fi


	## GET PARAMETERS
	local user=$USER
	local host=$HOSTNAME
	local path="$(shortenPath "$PWD" 20)"
	local git_branch="$(shortenPath "$(getGitBranch)" 10)"



	## UPDATE BASH PROMPT ELEMENTS
	FBP_USER=" $user "
	FBP_HOST=" $host "
	FBP_PWD=" $path "
	if [ -z "$git_branch" ]; then
		FBP_GIT=""
	else
		FBP_GIT=" $git_branch "
	fi



	## CHOOSE PS1 FORMAT IF INSIDE GIT REPO
	if [ -z "$(getGitBranch)" ]; then
		PS1=$FBP_PS1
	else
		PS1=$FBP_PS1_GIT
	fi
}






##------------------------------------------------------------------------------
##

	## INCLUDE EXTERNAL DEPENDENCIES
	## Only if the functions are not available
	## If not, search in `common` folder
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	if [ "$(type -t loadConfigFile)" != 'function' ];
	then
		source "$dir/../common/load_config.sh"
	fi

	if [ "$(type -t getFormatCode)" != 'function' ];
	then
		source "$dir/../common/color.sh"
	fi



	## DEFAULT CONFIGURATION
	## WARNING! Do not edit directly, use configuration files instead
	local font_color_user="white"
	local background_user="blue"
	local texteffect_user="bold"

	local font_color_host="white"
	local background_host="light-blue"
	local texteffect_host="bold"

	local font_color_pwd="dark-gray"
	local background_pwd="white"
	local texteffect_pwd="bold"

	local font_color_git="208" #208=orange
	local background_git="dark-gray"
	local texteffect_git="bold"

	local font_color_input="cyan"
	local background_input="none"
	local texteffect_input="bold"

	local separator_char=$'\uE0B0'

	local enable_vertical_padding=true
	local show_user=true
	local show_host=true
	local show_pwd=true
	local show_git=true



	## LOAD USER CONFIGURATION
	local user_config_file="$HOME/.config/scripts/fancy-bash-prompt.config"
	local sys_config_file="/etc/andresgongora/scripts/fancy-bash-prompt.config"
	if   [ -f $user_config_file ]; then
		loadConfigFile $user_config_file
	elif [ -f $sys_config_file ]; then
		loadConfigFile $sys_config_file
	fi



	## GENERATE COLOR FORMATING SEQUENCES
	## The sequences will confuse the bash promt. To tell the terminal that they are non-printint
	## characters, we must surround them by \[ and \]
	local no_color="\[$(getFormatCode -e reset)\]"
	local ps1_input_format="\[$(getFormatCode       -c $font_color_input -b $background_input -e $texteffect_input)\]"
	local ps1_input="${ps1_input_format} "

	local ps1_user_git=$(printSegment "\${FBP_HOST}" $font_color_user $background_user $background_host $texteffect_user)
	local ps1_host_git=$(printSegment "\${FBP_USER}" $font_color_host $background_host $background_pwd $texteffect_host)
	local ps1_pwd_git=$(printSegment "\${FBP_PWD}" $font_color_pwd $background_pwd $background_git $texteffect_pwd)
	local ps1_git_git=$(printSegment "\${FBP_GIT}" $font_color_git $background_git $background_input $texteffect_git)
	local ps1_user=$(printSegment "\${FBP_HOST}" $font_color_user $background_user $background_host $texteffect_user)
	local ps1_host=$(printSegment "\${FBP_USER}" $font_color_host $background_host $background_pwd $texteffect_host)
	local ps1_pwd=$(printSegment "\${FBP_PWD}" $font_color_pwd $background_pwd $background_input $texteffect_pwd)
	local ps1_git=""




	## Add extra new line on top of prompt
	if $enable_vertical_padding; then
		local vertical_padding="\n"
	else
		local vertical_padding=""
	fi



	## WINDOW TITLE
	## Prevent messed up terminal-window titles
	## Must be set in PS1
	case $TERM in
	xterm*|rxvt*)
		local titlebar='\[\033]0;\u:${NEW_PWD}\007\]'
		;;
	*)
		local titlebar=""
		;;
	esac



	## BASH PROMT - Generate promt and remove format from the rest
	FBP_PS1="$titlebar${vertical_padding}${ps1_user}${ps1_host}${ps1_pwd}${ps1_git}${ps1_input}"
	FBP_PS1_GIT="$titlebar${vertical_padding}${ps1_user_git}${ps1_host_git}${ps1_pwd_git}${ps1_git_git}${ps1_input}"



	## For terminal line coloring, leaving the rest standard
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG



	## ADD HOOK TO UPDATE PS1 AFTER EACH COMMAND
	## Bash provides an environment variable called PROMPT_COMMAND.
	## The contents of this variable are executed as a regular Bash command
	## just before Bash displays a prompt.
	## We want it to call our own command to truncate PWD and store it in NEW_PWD
	##
	## Also, call the hook once now to update current prompt
	PROMPT_COMMAND=prompt_command_hook
	prompt_command_hook
}
fancy_bash_prompt
unset fancy_bash_prompt



### EOF ###
