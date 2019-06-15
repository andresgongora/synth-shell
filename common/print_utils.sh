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
##	Helper functions to print on different places of the screen





##==============================================================================
##	TERMINAL CURSOR
##==============================================================================

enableTerminalLineWrap()
{
	printf '\e[?7h'
}


disableTerminalLineWrap()
{
	printf '\e[?7l'
}


saveCursorPosition()
{
	printf "\e[s"
}


moveCursorToSavedPosition()
{
	printf "\e[u"
}


moveCursorToRowCol()
{
	local row=$1
	local col=$2
	printf "\e[${row};${col}H"
}


moveCursorHome()
{
	printf "\e[;H"
}


moveCursorUp()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1A"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}A"
	fi
}


moveCursorDown()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1B"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}B"
	fi
}


moveCursorLeft()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1C"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}C"
	fi
}


moveCursorRight()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1D"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}D"
	fi
}




##==============================================================================
##	FUNCTIONS
##==============================================================================

##------------------------------------------------------------------------------
##
getTerminalNumRows()
{
	tput lines
}



##------------------------------------------------------------------------------
##
getTerminalNumCols()
{
	tput cols
}



##------------------------------------------------------------------------------
##
getTextNumRows()
{
	## COUNT ROWS
	local rows=$(echo -e "$1" | wc -l )
	echo "$rows"
}



##------------------------------------------------------------------------------
##
getTextNumCols()
{
	## COUNT COLUMNS - Remove color sequences before counting
	## 's/\x1b\[[0-9;]*m//g' to remove formatting sequences (\e=\033=\x1b)
	local columns=$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -L )
	echo "$columns"
}


##------------------------------------------------------------------------------
##
getTextShape()
{
	echo "$(getTextNumRows) $(getTextNumCols)"
}



##------------------------------------------------------------------------------
##
printWithOffset()
{
	local row=$1
	local col=$2
	local text=${@:3}


	## MOVE CURSOR TO TARGET ROW
	moveCursorDown "$row"


	## EDIT TEXT TO PRINT IN CORRECT COLUMN
	if [ $col -gt 0 ]; then
		col_spacer="\\\\e[${col}C"
		local text=$(echo "$text" |\
		             sed "s/^/$col_spacer/g;s/\\\\n/\\\\n$col_spacer/g")
	fi

	
	## PRINT TEXT WITHOUT LINE WRAP
	disableTerminalLineWrap
	printf "${text}\n"
	enableTerminalLineWrap
}










