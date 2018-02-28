#!/bin/sh

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	|                               BETTER LS                               |
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
##	BETTER LS (overrides 'ls' command, uses /usr/bin/ls)
##
##	Modifications:
##	- Colorized
##	- Human readable output
##	- Long timestamp
##
##	If no arguments passed
##		Show . and ..
##		Shows directories
##		Shows visible files
##		Shows hidden directories
##		Shows hidden files
##	else
##		Runs with argument and sorts directories first
##



################################################################################
##  FUNCTION                                                                  ##
################################################################################

function better-ls()
{
	if [ $# -eq 0 ]		# If no arguments passed
	then

		## Implied . and .., visible folders, then visible files
		/usr/bin/ls -d {.,..,*} -lA --color=auto --human-readable --time-style=long-iso --group-directories-first;
	
		
		## Then hidden directories and finally hidden files
		## -d		list folders/files themselves, not their content
		## .!(|.)	anything starting with '.' and not followed by '|.', meaning either nothing or another '.'
		if [ -d .!(|.) ]
		then
			echo ""
			/usr/bin/ls -d .!(|.) -l --color=auto --hide='..' --human-readable --time-style=long-iso --group-directories-first;
		fi
		
	else
		## Add user argument
		/usr/bin/ls -la --color=auto --human-readable --time-style=long-iso --group-directories-first "$@";	
	fi
}



################################################################################
##  ALIAS                                                                     ##
################################################################################

alias ls='better-ls'


### EOF ###

