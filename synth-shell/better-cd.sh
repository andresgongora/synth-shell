#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2020, Andres Gongora <mail@andresgongora.com>.          |
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
##	DESCRIPTION:
##	Overrides 'cd' command to either work as usual if a directory is
##	specified, or to offer a quick navigation menu if none is specified.
##	Example:
##	cd /home/ ## takes you to /home
##	cd        ## brings up the navigation menu
##
##



##==============================================================================
##	BETTER CD
##==============================================================================

cd()
{
	echo "$@"
	local CD="$(which cd)"


	## IF NO ARGUMENTS PASSED -> run better cd version on current folder
	if [ $# -eq 0 ]; then

		echo "BETTER"


	## IF ARGUMENTS PASSED -> run standard cd	
	else
		$CD "$@"	
	fi
}

### EOF ###

