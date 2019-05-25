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
##
##
##
##	
##	REFFERENCES
##
##	* http://tldp.org/HOWTO/Bash-Prompt-HOWTO/index.html
##
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
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	source "$dir/../common/load_config.sh"
	source "$dir/../common/color.sh"



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

	local font_color_input="cyan"
	local background_input="none"
	local texteffect_input="bold"

	local separator_char=$'\uE0B0'
	


	## LOAD USER CONFIGURATION
	local config_file="$HOME/Software/scripts/terminal/fancy-bash-prompt.config"
	overrideConfig $config_file

	

	## GENERATE COLOR FORMATING SEQUENCES
	## The sequences will confuse the bash promt. To tell the terminal that they are non-printint
	## characters, we must surround them by \[ and \]
	local no_color="\[$(getFormatCode -e reset)\]"
	local ps1_user_format="\[$(getFormatCode    -c $font_color_user  -b $background_user  -e $texteffect_user)\]"
	local ps1_host_format="\[$(getFormatCode    -c $font_color_host  -b $background_host  -e $texteffect_host)\]"
	local ps1_pwd_format="\[$(getFormatCode     -c $font_color_pwd   -b $background_pwd   -e $texteffect_pwd)\]"
	local ps1_input_format="\[$(getFormatCode   -c $font_color_input -b $background_input -e $texteffect_input)\]"
	local separator_1_format="\[$(getFormatCode -c $background_user  -b $background_host)\]"
	local separator_2_format="\[$(getFormatCode -c $background_host  -b $background_pwd)\]"
	local separator_3_format="\[$(getFormatCode -c $background_pwd)\]"

	

	## GENERATE USER/HOST/PWD TEXT
	local ps1_user="${ps1_user_format} \u "
	local ps1_host="${ps1_host_format} \h "
	local ps1_pwd="${ps1_pwd_format} \${NEW_PWD} "
	local ps1_input="${ps1_input_format} "



	## GENERATE SEPARATORS
	local separator_1="${separator_1_format}${separator_char}"
	local separator_2="${separator_2_format}${separator_char}"
	local separator_3="${separator_3_format}${separator_char}$no_color"



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
	PS1="$titlebar\n${ps1_user}${separator_1}${ps1_host}${separator_2}${ps1_pwd}${separator_3}${ps1_input}"

	

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
