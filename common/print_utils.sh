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
##	FUNCTIONS
##==============================================================================

##------------------------------------------------------------------------------
##
getTextShape()
{
	## COUNT ROWS
	local rows=$(echo -e "$1" | wc -l )

	## COUNT COLUMNS - Remove color sequences before counting
	## 's/\x1b\[[0-9;]*m//g' to remove formatting sequences (\e=\033=\x1b)
	local columns=$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -L )

	echo "$rows $columns"
}



##------------------------------------------------------------------------------
##
printWithOffset()
{
	local row=$1
	local col=$2
	local text=${@:3}


	## MOVE CURSOR TO TARGET ROW
	if [ $row -gt 0 ]; then
		printf "\e[${row}B"
	fi 


	## EDIT TEXT TO PRINT IN CORRECT COLUMN
	if [ $col -gt 0 ]; then
		col_spacer="\\\\e[${col}C"
		local text=$(echo "$text" |\
		             sed "s/^/$col_spacer/g;s/\\\\n/\\\\n$col_spacer/g")
	fi

	
	## PRINT TEXT WITHOUT LINE WRAP
	printf "\e[?7l${text}\e[?7h\n"
}


