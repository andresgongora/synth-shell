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

function beter-ls()
{
	if [ $# -eq 0 ]	# If no arguments passed
	 	then
	 	## First implied . and .. directories
	 	/usr/bin/ls -d .  -l --color=auto --human-readable --time-style=long-iso --group-directories-first;
	 	/usr/bin/ls -d .. -l --color=auto --human-readable --time-style=long-iso --group-directories-first;
	 	
	 	echo ""
	 	
		## First visible directories, then visible files
		/usr/bin/ls -d * -lA --color=auto --human-readable --time-style=long-iso --group-directories-first;
		
		echo ""
		
		## Then hidden directories and finally hidden files
		## -d		list folders/files themselves, not their content
		## .!(|.)	anything starting with '.' and not followed by '|.', meaning either nothing or another '.'  
		/usr/bin/ls -d .!(|.) -l --color=auto --hide='..' --human-readable --time-style=long-iso --group-directories-first;		
		
	else
		## Add user argument
		/usr/bin/ls -la --color=auto --human-readable --time-style=long-iso --group-directories-first "$@";	
	fi
}



################################################################################
##  ALIAS                                                                     ##
################################################################################

alias ls='beter-ls'


# EOF

