#!/bin/bash

##   +-----------------------------------+-----------------------------------+
##   |                                                                       |
##   | Copyright (c) 2019, Andres Gongora <mail@andresgongora.com>.          |
##   |                                                                       |
##   | This program is free software: you can redistribute it and/or modify  |
##   | it under the terms of the GNU General Public License as published by  |
##   | the Free Software Foundation, either version 3 of the License, or     |
##   | (at your option) any later version.                                   |
##   |                                                                       |
##   | This program is distributed in the hope that it will be useful,       |
##   | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##   | GNU General Public License for more details.                          |
##   |                                                                       |
##   | You should have received a copy of the GNU General Public License     |
##   | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##   |                                                                       |
##   +-----------------------------------------------------------------------+


##
##	DESCRIPTION
##	===========
##
##	Script to colorize terminal text.
##	It works in either of two ways, either by providing the formatting
##	sequences that should be added to the text, or by directly wrapping
##	the text with the desired control sequences
##
##
##
##
##
##	USAGE
##	=====
##
##	Formating a text directly:
##		FORMATTED_TEXT=$(formatText "Hi!" -c red -b 13 -e bold)
##		echo -e "$FORMATTED_TEXT"
##
##	Getting the control sequences:
##		FORMAT=$(getFormatCode -c blue -b yellow -e bold -e blink)
##		NONE=$(getFormatCode -e none)
##		echo -e $FORMAT"Hello"$NONE
##
##	Options (More than one code may be specified)
##	-c	color name or 256bit code for font face
##	-b	background color name or 256bit code
##	-e	effect name (e.g. bold, blink, etc.)
##
##
##
##
##
##	BASH TEXT FORMATING
##	===================
##
##	Colors and text formatting can be achieved by preceding the text
##	with an escape sequence. An escape sequence starts with an <ESC>
##	character (commonly \e[), followed by one or more formatting codes
##	(its possible) to apply more that one color/effect at a time),
##	and finished by a lower case m. For example, the formatting code 1 
##	tells the terminal to print the text bold face. This is acchieved as:
##		\e[1m Hello World!
##
##	But if nothing else is specified, then eveything that may be printed
##	after 'Hello world!' will be bold face as well. The code 0 is thus
##	meant to remove all formating from the text and return to normal:
##		\e[1m Hello World! \e[0m
##
##	It's also possible to paint the text in color (codes 30 to 37 and
##	codes 90 to 97), or its background (codes 40 to 47 and 100 to 107).
##	Red has code 31:
##		\e[31m Hello World! \e[0m
##
##	More than one code can be applied at a time. Codes are separated by
##	semicolons. For example, code 31 paints the text in red. Thus,
##	the following would print in red bold face:
##		\e[1;31m Hello World! \e[0m
##
##	Some formatting sequences are, in fact, comprised of two codes
##	that must go together. For example, the code 38;5; tells the terminal
##	that the next code (after the semicolon) should be interpreted as
##	a 256 bit formatting color. So, for example, the code 82 is a light
##	green. We can paint the text using this code as follows, plus bold
##	face as follows - but notice that not all terminal support 256 colors:##
##		\e[1;38;5;82m Hello World! \e[0m
##
##	For a detailed list of all codes, this site has an excellent guide:
##	https://misc.flogisoft.com/bash/tip_colors_and_formatting
##
##
##
##
##
##	TODO: When requesting an 8 bit colorcode, detect if terminal supports
##	256 bits, and return appropriate code instead
##
##	TODO: Improve this description/manual text
##
##	TODO: Currently, if only one parameter is passed, its treated as a
##	color. Addsupport to also detect whether its an effect code.
##		Now: getFormatCode blue == getFormatCode -c blue
##		Add: getFormatCode bold == getFormatCode -e bold
##
##	TODO: Clean up this script. Prevent functions like "get8bitCode()"
##	to be accessible from outside. These are only a "helper" function
##	that should only be available to this script
##






##==============================================================================
##	CODE PARSERS
##==============================================================================

get8bitCode()
{
	CODE=$1
	case $CODE in
		default)
			echo 9
			;;
		none)
			echo 9
			;;
		black)
			echo 0
			;;
		red)
			echo 1
			;;
		green)
			echo 2
			;;
		yellow)
			echo 3
			;;
		blue)
			echo 4
			;;
		magenta)
			echo 5
			;;
		cyan)
			echo 6
			;;
		light-gray)
			echo 7
			;;
		dark-gray)
			echo 60
			;;
		light-red)
			echo 61
			;;
		light-green)
			echo 62
			;;
		light-yellow)
			echo 63
			;;
		light-blue)
			echo 64
			;;
		light-magenta)
			echo 65
			;;
		light-cyan)
			echo 66
			;;
		white)
			echo 67
			;;
		*)
			echo 0
	esac
}






getColorCode()
{
	COLOR=$1

	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "38;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 30))
		echo $COLORCODE
	fi
}






getBackgroundCode()
{
	COLOR=$1

	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "48;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 40))
		echo $COLORCODE
	fi
}






getEffectCode()
{
	EFFECT=$1
	NONE=0

	case $EFFECT in
	none)
		echo $NONE
		;;
	default)
		echo $NONE
		;;
	bold)
		echo 1
		;;
	bright)
		echo 1
		;;
	dim)
		echo 2
		;;
	underline)
		echo 4
		;;
	blink)
		echo 5
		;;
	reverse)
		echo 7
		;;
	hidden)
		echo 8
		;;
	strikeout)
		echo 9
		;;
	*)
		echo $NONE
	esac
}






getFormattingSequence()
{
	START='\e[0;'
	MIDLE=$1
	END='m'
	echo -n "$START$MIDLE$END"
}


##==============================================================================
##	AUX
##==============================================================================

applyCodeToText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	TEXT=$1
	CODE=$2
	echo -n "$CODE$TEXT$RESET"
}




##==============================================================================
##	MAIN FUNCTIONS
##==============================================================================

getFormatCode()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))

	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "$RESET"

	## 1 ARGUMENT -> ASSUME TEXT COLOR
	elif [ "$#" -eq 1 ]; then
		TEXT_COLOR=$(getFormattingSequence $(getColorCode $1))
		echo -n "$TEXT_COLOR"

	## ARGUMENTS PROVIDED
	else
		FORMAT=""
		while [ "$1" != "" ]; do

			## PROCESS ARGUMENTS
			TYPE=$1
			ARGUMENT=$2
			case $TYPE in
			-c)
				CODE=$(getColorCode $ARGUMENT)
				;;
			-b)
				CODE=$(getBackgroundCode $ARGUMENT)
				;;
			-e)
				CODE=$(getEffectCode $ARGUMENT)
				;;
			*)
				CODE=""
			esac

			## ADD CODE SEPARATOR IF NEEDED
			if [ "$FORMAT" != "" ]; then
				FORMAT="$FORMAT;"
			fi

			## APPEND CODE
			FORMAT="$FORMAT$CODE"

			# Remove arguments from stack
			shift
			shift
		done

		## APPLY FORMAT TO TEXT
		FORMAT_CODE=$(getFormattingSequence $FORMAT)
		echo -n "${FORMAT_CODE}"
	fi

}






formatText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))

	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "${RESET}"

	## ONLY A STRING PROVIDED -> Append reset sequence
	elif [ "$#" -eq 1 ]; then
		TEXT=$1
		echo -n "${TEXT}${RESET}"

	## ARGUMENTS PROVIDED
	else
		TEXT=$1
		FORMAT_CODE=$(getFormatCode "${@:2}")
		applyCodeToText "$TEXT" "$FORMAT_CODE"
	fi
}






removeColorCodes()
{
	## TODO
	printf "$1" | sed 's/\x1b\[[0-9;]*m//g'
}



##==============================================================================
##	DEBUG
##==============================================================================

#formatText "$@"

#FORMATTED_TEXT=$(formatText "HELLO WORLD!!" -c red -b 13 -e bold -e blink -e strikeout)
#echo -e "$FORMATTED_TEXT"

#FORMAT=$(getFormatCode -c blue -b yellow)
#NONE=$(getFormatCode -e none)
#echo -e $FORMAT"Hello"$NONE
