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



##------------------------------------------------------------------------------
##
printTwoElementsSideBySide()
{
	## GET ELEMENTS TO PRINT
	local element_1=$1
	local element_2=$2
	local print_cols_max=$3


	## GET PRINTABLE AREA SIZE
	local term_cols=$(getTerminalNumCols)
	if [ ! -z "$print_cols_max" ]; then
		local term_cols=$(( ( $term_cols > $print_cols_max ) ?\
			$print_cols_max : $term_cols ))
	fi


	## GET ELEMENT SHAPES
	local e_1_cols=$(getTextNumCols "$element_1")
	local e_1_rows=$(getTextNumRows "$element_1")
	local e_2_cols=$(getTextNumCols "$element_2")
	local e_2_rows=$(getTextNumRows "$element_2")


	## COMPUTE OPTIMAL HORIZONTAL PADDING
	local free_cols=$(( $term_cols - $e_1_cols - $e_2_cols ))
	local h_pad=$(( $free_cols/3 ))
	local e_1_h_pad=$h_pad
	local e_2_h_pad=$(( $e_1_cols + 2*$h_pad ))


	## COMPUTE OPTIMAL VERTICAL PADDING
	local e_1_v_pad=$(( ( $e_1_rows > $e_2_rows ) ?\
		0 : (( ($e_2_rows - $e_1_rows)/2 )) ))
	local e_2_v_pad=$(( ( $e_2_rows > $e_1_rows ) ?\
		0 : (( ($e_1_rows - $e_2_rows)/2 )) ))
	

	## PRINT ELEMENTS
	saveCursorPosition
	printWithOffset $e_1_v_pad $e_1_h_pad "$element_1"
	moveCursorToSavedPosition
	printWithOffset $e_2_v_pad $e_2_h_pad "$element_2"
	moveCursorToSavedPosition


	## LEAVE CURSOR AT "SAFE" POSITION
	local max_rows=$(( ( $e_1_rows > $e_2_rows ) ? $e_1_rows : $e_2_rows ))
	moveCursorDown "$max_rows"
}






