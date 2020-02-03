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
##	DESCRIPTION:
##	Overrides 'ls' command to be more useful/easier to read. The following
##	main modifications are applied:
##	- Colorized
##	- Human readable output
##	- Long timestamp
##
##
##
##
##	HOW IF WORKS:
##	- If no arguments passed
##		Show . and ..
##		Shows directories
##		Shows visible files
##		Shows hidden directories
##		Shows hidden files
##	- else
##		Runs with argument, but sorts directories first and prints color
##
##
##
##
##	DEV NOTES:
##
## 	shopt -s extglob 
##		This must be enabled for extglob wildcards to work (eg !).
##
## 	files=$(/usr/bin/ls -U * 2> /dev/null | wc -l)
##		Create a list of all files in '*' and count it with wc -l
##		If zero there is no file. -U disables sorting for
##		shorter response times.
##
##	hidden_files=$(/usr/bin/ls -U -d .[^.]* 2> /dev/null | wc -l)
##		Same as above, but for '.[^.]*', which includes all
##		hidden files but ommits '.' and '..' .
##
##	.[^.]*
##		Anything starting with '.', followed by one char that can not be
##		'.', and then as many (or any) characters as wanted.
##




##==============================================================================
##	BETTER LS
##==============================================================================

function better_ls()
{
	shopt -s extglob
	local LS="$(which ls)"


	## IF NO ARGUMENTS PASSED -> run better ls version on current folder
	if [ $# -eq 0 ]; then

		## IF THE CURRENT FOLDER IS NOT EMPTY -> Display all
		files=$($LS -U * 2> /dev/null | wc -l)	
		if [ "$files" != "0" ]
		then 
			## List implied . and .., visible folders, then visible files
			$LS -d {.,..,*} -lA --color=auto --human-readable \
				--time-style=long-iso --group-directories-first;


			## List hidden folders and files (only if they exist)
			hidden_files=$($LS -U -d .[^.]* 2> /dev/null | wc -l)	
			if [ "$hidden_files" != "0" ]
			then
				echo ""
				$LS -d .[^.]* -l --color=auto --hide='..' \
					--human-readable --time-style=long-iso \
					--group-directories-first;
			fi

		## IF THE CURRENT FOLDER IS EMPTY -> List . and ..
		else
			$LS -d {.,..,} -lA --color=auto --human-readable \
				--time-style=long-iso --group-directories-first;
		fi


	## IF ARGUMENTS PASSED -> run standard ls but with some tweaks (eg: colors)		
	else
		$LS --color=auto --human-readable --time-style=long-iso \
		    --group-directories-first "$@";	
	fi
}



## Override default ls
alias ls='better_ls'


### EOF ###


