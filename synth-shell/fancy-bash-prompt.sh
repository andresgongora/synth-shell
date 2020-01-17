#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2018-2020, Andres Gongora <mail@andresgongora.com>.     |
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
##	DESCRIPTION
##
##	This script updates your "PS1" environment variable to display colors.
##	Additionally, it also shortens the name of your current path to a 
##	maximum 25 characters, which is quite useful when working in deeply
##	nested folders.
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
##	getGitInfo
##	Returns current git branch for current directory, if (and only if)
##	the current directory is part of a git repository, and git is installed.
##
##	In addition, it adds a symbol to indicate the state of the repository.
##	By default, these symbols and their meaning are (set globally):
##
##		UPSTREAM	NO CHANGE		DIRTY
##		up to date	FBP_GIT_SYNCED		FBP_GIT_DIRTY
##		ahead		FBP_GIT_AHEAD		FBP_GIT_DIRTY_AHEAD
##		behind		FBP_GIT_BEHIND		FBP_GIT_DIRTY_BEHIND
##		diverged	FBP_GIT_DIVERGED	FBP_GIT_DIRTY_DIVERGED		
##
##	Returns an empty string otherwise.
##
##	Inspired by twolfson's sexy-bash-prompt:
##	https://github.com/twolfson/sexy-bash-prompt
##
getGitBranch()
{
	if ( which git > /dev/null 2>&1 ); then

		## CHECK IF IN A GIT REPOSITORY, OTHERWISE SKIP
		local branch=$(git branch 2> /dev/null |\
		             sed -n '/^[^*]/d;s/*\s*\(.*\)/\1/p')	

		if [[ -n "$branch" ]]; then

			## GET GIT STATUS
			## This information contains whether the current branch is
			## ahead, behind or diverged (ahead & behind), as well as
			## whether any file has been modified locally (is dirty).
			## --porcelain: script friendly outbut.
			## -b:          show branch tracking info.
			## -u no:       do not list untracked/dirty files
			## From the first line we get whether we are synced, and if
			## there are more lines, then we know it is dirty.
			## NOTE: this requires that tyou fetch your repository,
			##       otherwise your information is outdated.
			local is_dirty=false &&\
				       [[ -n "$(git status --porcelain)" ]] &&\
				       is_dirty=true
			local is_ahead=false &&\
				       [[ "$(git status --porcelain -u no -b)" == *"ahead"* ]] &&\
				       is_ahead=true
			local is_behind=false &&\
				        [[ "$(git status --porcelain -u no -b)" == *"behind"* ]] &&\
				        is_behind=true


			## SELECT SYMBOL
			if   $is_dirty && $is_ahead && $is_behind; then
				local symbol=$FBP_GIT_DIRTY_DIVERGED
			elif $is_dirty && $is_ahead; then
				local symbol=$FBP_GIT_DIRTY_AHEAD
			elif $is_dirty && $is_behind; then
				local symbol=$FBP_GIT_DIRTY_BEHIND
			elif $is_dirty; then
				local symbol=$FBP_GIT_DIRTY
			elif $is_ahead && $is_behind; then
				local symbol=$FBP_GIT_DIVERGED
			elif $is_ahead; then
				local symbol=$FBP_GIT_AHEAD
			elif $is_behind; then
				local symbol=$FBP_GIT_BEHIND
			else
				local symbol=$FBP_GIT_SYNCED
			fi


			## RETURN STRING
			echo "$branch $symbol"	
		fi
	fi
	
	## DEFAULT
	echo ""
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
	if [ -z "$separator_char" ]; then local separator_char='\uE0B0'; fi



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
	if [ "$(type -t shortenPath)" != 'function' ];
	then
		local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
		source "$dir/../bash-tools/bash-tools/shorten_path.sh"
	fi
	if [ "$(type -t removeColorCodes)" != 'function' ];
	then
		local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
		source "$dir/../bash-tools/bash-tools/color.sh"
	fi



	## GET PARAMETERS
	local user=$USER
	local host=$HOSTNAME
	local path="$(shortenPath "$PWD" 20)"
	local git_branch="$(shortenPath "$(getGitBranch)" 10)"



	## UPDATE BASH PROMPT ELEMENTS
	FBP_USER="$user"
	FBP_HOST="$host"
	FBP_PWD="$path"
	if [ -z "$git_branch" ]; then
		FBP_GIT=""
	else
		FBP_GIT="$git_branch"
	fi



	## CHOOSE PS1 FORMAT IF INSIDE GIT REPO
	if [ ! -z "$(getGitBranch)" ] && $FBP_GIT_SHOW; then
		PS1=$FBP_PS1_GIT
	else
		PS1=$FBP_PS1
	fi
}






##------------------------------------------------------------------------------
##

	## INCLUDE EXTERNAL DEPENDENCIES
	## Only if the functions are not available
	## If not, search in `common` folder
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	if [ "$(type -t getFormatCode)" != 'function' ]; then
		source "$dir/../bash-tools/bash-tools/color.sh"
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

	local font_color_git="light-gray"
	local background_git="dark-gray"
	local texteffect_git="bold"

	local font_color_input="cyan"
	local background_input="none"
	local texteffect_input="bold"

	local separator_char='\uE0B0'
	local enable_vertical_padding=true

	local show_git=true
	local git_symbol_synced=''
	local git_symbol_unpushed='△'
	local git_symbol_unpulled='▽'
	local git_symbol_unpushedunpulled='○'
	local git_symbol_dirty='!'
	local git_symbol_dirty_unpushed='▲'
	local git_symbol_dirty_unpulled='▼'
	local git_symbol_dirty_unpushedunpulled='●'



	## LOAD USER CONFIGURATION
	local user_config_file="$HOME/.config/synth-shell/fancy-bash-prompt.config"
	local sys_config_file="/etc/andresgongora/synth-shell/fancy-bash-prompt.config"
	if   [ -f $user_config_file ]; then
		source $user_config_file
	elif [ -f $sys_config_file ]; then
		source $sys_config_file
	fi



	## GENERATE COLOR FORMATTING SEQUENCES
	## The sequences will confuse the bash prompt. To tell the terminal that they are non-printing
	## characters, we must surround them by \[ and \]
	local no_color="\[$(getFormatCode -e reset)\]"
	local ps1_input_format="\[$(getFormatCode       -c $font_color_input -b $background_input -e $texteffect_input)\]"
	local ps1_input="${ps1_input_format} "

	local ps1_user_git=$(printSegment " \${FBP_USER} " $font_color_user $background_user $background_host $texteffect_user)
	local ps1_host_git=$(printSegment " \${FBP_HOST} " $font_color_host $background_host $background_pwd $texteffect_host)
	local ps1_pwd_git=$(printSegment " \${FBP_PWD} " $font_color_pwd $background_pwd $background_git $texteffect_pwd)
	local ps1_git_git=$(printSegment " \${FBP_GIT} " $font_color_git $background_git $background_input $texteffect_git)

	local ps1_user=$(printSegment " \${FBP_USER} " $font_color_user $background_user $background_host $texteffect_user)
	local ps1_host=$(printSegment " \${FBP_HOST} " $font_color_host $background_host $background_pwd $texteffect_host)
	local ps1_pwd=$(printSegment " \${FBP_PWD} " $font_color_pwd $background_pwd $background_input $texteffect_pwd)
	local ps1_git=""



	## MAKE GIT OPTIONS GLOBALLY AVAILABLE
	## This is needed because each time the prompt updates,
	## it must re-check the status of the current git repository,
	## and to do so, it must remember the user's configuation
	FBP_GIT_SHOW=$show_git
	FBP_GIT_SYNCED=$git_symbol_synced
	FBP_GIT_AHEAD=$git_symbol_unpushed
	FBP_GIT_BEHIND=$git_symbol_unpulled
	FBP_GIT_DIVERGED=$git_symbol_unpushedunpulled
	FBP_GIT_DIRTY=$git_symbol_dirty
	FBP_GIT_DIRTY_AHEAD=$git_symbol_dirty_unpushed
	FBP_GIT_DIRTY_BEHIND=$git_symbol_dirty_unpulled
	FBP_GIT_DIRTY_DIVERGED=$git_symbol_dirty_unpushedunpulled



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
		local titlebar="\[\033]0;\${FBP_USER}@\${FBP_HOST}: \${FBP_PWD}\007\]"
		;;
	*)
		local titlebar=""
		;;
	esac



	## BASH PROMPT - Generate prompt and remove format from the rest
	FBP_PS1="${titlebar}${vertical_padding}${ps1_user}${ps1_host}${ps1_pwd}${ps1_git}${ps1_input}"
	FBP_PS1_GIT="${titlebar}${vertical_padding}${ps1_user_git}${ps1_host_git}${ps1_pwd_git}${ps1_git_git}${ps1_input}"



	## For terminal line coloring, leaving the rest standard
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG



	## ADD HOOK TO UPDATE PS1 AFTER EACH COMMAND
	## Bash provides an environment variable called PROMPT_COMMAND.
	## The contents of this variable are executed as a regular Bash command
	## just before Bash displays a prompt.
	## We want it to call our own command to truncate PWD and store it in NEW_PWD
	PROMPT_COMMAND=prompt_command_hook



}
## CALL SCRIPT
## CHECK IF COLOR SUPPORTED
## - Check if compliant with Ecma-48 (ISO/IEC-6429)
##	- Call script
##	- Unset script
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	fancy_bash_prompt
	unset fancy_bash_prompt
fi



### EOF ###
