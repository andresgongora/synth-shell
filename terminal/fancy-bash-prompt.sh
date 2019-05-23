#!/bin/bash

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	| Copyright (c) 2018, Andres Gongora <mail@andresgongora.com>.          |
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
##	Addicitionally, it also shortens the name of your current part to maximum
##	25 characters, which is quite useful when working in deeply nested folders.
##
##
##
##
##	FUNCTIONS
##
##	* bash_prompt_command()
##	  This function takes your current working directory and stores a shortened
##	  version in the variable "NEW_PWD".
##
##	* bash_prompt()
##	  This function colorizes the bash promt. The exact color scheme can be
##	  configured here. The structure of the function is as follows:
##		1. A. Definition of available colors for 16 bits.
##		1. B. Definition of some colors for 256 bits (add your own).
##		2. Configuration >> EDIT YOUR PROMT HERE<<.
##		4. Generation of color codes.
##		5. Generation of window title (some terminal expect the first
##		   part of $PS1 to be the window title)
##		6. Formating of the bash promt ($PS1).
##
##	* Main script body:	
##	  It calls the adequate helper functions to colorize your promt and sets
##	  a hook to regenerate your working directory "NEW_PWD" when you change it.
## 




##==============================================================================
##	FUNCTIONS
##==============================================================================

##
##	ARRANGE $PWD AND STORE IT IN $NEW_PWD
##	* The home directory (HOME) is replaced with a ~
##	* The last pwdmaxlen characters of the PWD are displayed
##	* Leading partial directory names are striped off
##		/home/me/stuff -> ~/stuff (if USER=me)
##		/usr/share/big_dir_name -> ../share/big_dir_name (if pwdmaxlen=20)
##
##	Original source: WOLFMAN'S color bash promt
##	https://wiki.chakralinux.org/index.php?title=Color_Bash_Prompt#Wolfman.27s
##
bash_prompt_command() {
	# How many characters of the $PWD should be kept
	local pwdmaxlen=25

	# Indicate that there has been dir truncation
	local trunc_symbol=".."

	# Store local dir
	local dir=${PWD##*/}

	# Which length to use
	pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))

	NEW_PWD=${PWD/#$HOME/\~}
	
	local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

	# Generate name
	if [ ${pwdoffset} -gt "0" ]
	then
		NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
		NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
	fi
}



##==============================================================================
bash_prompt() {

	## INCLUDE EXTERNAL DEPENDENCIES
	local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	source "$DIR/../common/load_config.sh"
	source "$DIR/../common/color.sh"


	## LOAD CONFIGURATION
	## Search for valid configuration file. If not found,
	## resort to default location (same fodler as script).
	local CONFIG_FILE="$HOME/.config/scripts/terminal/fancy-bash-prompt.config"
	if [ ! -f $CONFIG_FILE ]; then
		local CONFIG_FILE="$DIR/fancy-bash-prompt.config"
	fi	

	local FONT_COLOR_USER=$(LoadParam "FONT_COLOR_USER" "$CONFIG_FILE")
	local BACKGROUND_USER=$(LoadParam "BACKGROUND_USER" "$CONFIG_FILE")
	local TEXTEFFECT_USER=$(LoadParam "TEXTEFFECT_USER" "$CONFIG_FILE")

	local FONT_COLOR_HOST=$(LoadParam "FONT_COLOR_HOST" "$CONFIG_FILE")
	local BACKGROUND_HOST=$(LoadParam "BACKGROUND_HOST" "$CONFIG_FILE")
	local TEXTEFFECT_HOST=$(LoadParam "TEXTEFFECT_HOST" "$CONFIG_FILE")

	local FONT_COLOR_PWD=$(LoadParam "FONT_COLOR_PWD" "$CONFIG_FILE")
	local BACKGROUND_PWD=$(LoadParam "BACKGROUND_PWD" "$CONFIG_FILE")
	local TEXTEFFECT_PWD=$(LoadParam "TEXTEFFECT_PWD" "$CONFIG_FILE")

	local FONT_COLOR_INPUT=$(LoadParam "FONT_COLOR_INPUT" "$CONFIG_FILE")
	local BACKGROUND_INPUT=$(LoadParam "BACKGROUND_INPUT" "$CONFIG_FILE")
	local TEXTEFFECT_INPUT=$(LoadParam "TEXTEFFECT_INPUT" "$CONFIG_FILE")

	
	## GENERATE COLOR FORMATING SEQUENCES
	## The sequences will confuse the bash promt. To tell the terminal that they are non-printint
	## characters, we must surround them by \[ and \]
	local NO_COLOR="\[$(getFormatCode -e reset)\]"
	local PS1_USER_FORMAT="\[$(getFormatCode -c $FONT_COLOR_USER -b $BACKGROUND_USER -e $TEXTEFFECT_USER)\]"
	local PS1_HOST_FORMAT="\[$(getFormatCode -c $FONT_COLOR_HOST -b $BACKGROUND_HOST -e $TEXTEFFECT_HOST)\]"
	local PS1_PWD_FORMAT="\[$(getFormatCode -c $FONT_COLOR_PWD -b $BACKGROUND_PWD -e $TEXTEFFECT_PWD)\]"
	local PS1_INPUT_FORMAT="\[$(getFormatCode -c $FONT_COLOR_INPUT -b $BACKGROUND_INPUT -e $TEXTEFFECT_INPUT)\]"
	local SEPARATOR_1_FORMAT="\[$(getFormatCode -c $BACKGROUND_USER -b $BACKGROUND_HOST)\]"
	local SEPARATOR_2_FORMAT="\[$(getFormatCode -c $BACKGROUND_HOST -b $BACKGROUND_PWD)\]"
	local SEPARATOR_3_FORMAT="\[$(getFormatCode -c $BACKGROUND_PWD)\]"

	
	## GENERATE USER/HOST/PWD TEXT
	local PS1_USER="${PS1_USER_FORMAT} \u "
	local PS1_HOST="${PS1_HOST_FORMAT} \h "
	local PS1_PWD="${PS1_PWD_FORMAT} \${NEW_PWD} "
	local PS1_INPUT="${PS1_INPUT_FORMAT} "


	## GENERATE SEPARATORS WITH FANCY TRIANGLE
	local TRIANGLE=$'\uE0B0'
	local SEPARATOR_1="${SEPARATOR_1_FORMAT}${TRIANGLE}"
	local SEPARATOR_2="${SEPARATOR_2_FORMAT}${TRIANGLE}"
	local SEPARATOR_3="${SEPARATOR_3_FORMAT}${TRIANGLE}$NO_COLOR"


	## BASH PROMT - Generate promt and remove format from the rest
	PS1="$TITLEBAR\n${PS1_USER}${SEPARATOR_1}${PS1_HOST}${SEPARATOR_2}${PS1_PWD}${SEPARATOR_3}${PS1_INPUT}"


	## WINDOW TITLE - Prevent messed up terminal-window titles
	case $TERM in
	xterm*|rxvt*)
		local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
		;;
	*)
		local TITLEBAR=""
		;;
	esac
	

	## For terminal line coloring, leaving the rest standard
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG
}




##==============================================================================
##	MAIN
##==============================================================================

##	Bash provides an environment variable called PROMPT_COMMAND. 
##	The contents of this variable are executed as a regular Bash command 
##	just before Bash displays a prompt. 
##	We want it to call our own command to truncate PWD and store it in NEW_PWD
PROMPT_COMMAND=bash_prompt_command

##	Call bash_promnt only once, then unset it (not needed any more)
##	It will set $PS1 with colors and relative to $NEW_PWD, 
##	which gets updated by $PROMT_COMMAND on behalf of the terminal
bash_prompt
unset bash_prompt



### EOF ###
