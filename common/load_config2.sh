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
##



##==============================================================================
##  FUNCTION
##==============================================================================

##------------------------------------------------------------------------------
##
##	overrideConfig
##
##	It will iterate through the configuration file searching for lines
##	containing key-parameter pairs. If there is a variable in the scripts
##	scope with the same name as the key, it will write to it the value
##	of the configuration parameter. 
##
##	Arguments:
##	1. Path to configuration file
##
overrideConfig() {

	## CHECK IF CONFIGURATION FILE EXISTS
	local config_file=$1
	if [ -f $config_file ]; then
		
		## ITERATE THROUGH LINES IN CONFIGURATION FILE
		while IFS="" read -r p || [ -n "$p" ]
		do
			## REMOVE COMMENTS FROM LINE
			local trimmed_line=$(echo $p | sed '/^$/d;/^\#/d;/\#.*$/d;/\n/d;')

			## CONVERT LINE INTO SCRIPT PARAMETERS
			set -- $trimmed_line

			## LOAD CONFIG IF AT LEAST 2 PARAMETERS
			## Config-key-name and desired config value
			if [ "$#" -gt 1 ]; then

				## ASSING HUMAN READABLE NAMES
				local config_key_name=$1
				local config_param=${@:2}
				eval config_key_current_value=\$$config_key_name
		
				## REASSING CONFIG PARAMETER TO KEY
				## ONLY IF ALREADY DECLARED AND NOT EMPTY
				## This is meant to avoid loading config parameters
				## from the config file that are not even used by the caller
				if [ ! -z "$config_key_current_value" ]; then

					## LOAD CONFIG PARAMETER
					export "${config_key_name}"="$config_param"
				fi				
			fi
		done < $config_file
	fi
}


#declare -n
#eval
#set (-a)


##==============================================================================
##  FOR DEBUGGING ONLY
##==============================================================================

fun()
{
	local NAME_4="Default value 4"	
	loadConfig "/home/andy/Software/scripts/common/config"
	echo "Final value:"
	echo $NAME_4
}
fun

echo "Here should be NOTHING:"
echo $NAME_4
unset NAME_4


#NAME=$(LoadParam NAME2)
#echo "$NAME"


#NAME=$(LoadParam NAME3 "./config")
#echo "$NAME"


#NAME=$(LoadParam NAME8 "8" "./config")
#echo "$NAME"


#NAME=$(LoadParam NAME8 "./config")
#echo "$NAME"


#NAME=$(LoadParam VAL1 "./config")
#echo "$NAME"


#NAME=$(LoadParam STR "8" "./config")
#echo "$NAME"


