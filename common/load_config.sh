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
##	DESCRIPTION:
## 



##	If any fails (exit code not 0), stop script
##	Exit code 0        Success
##	Exit code 1        General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations
##	Exit code 2        Misuse of shell builtins (according to Bash documentation)        Example: empty_function() {}
set -e


##==============================================================================
##  FUNCTIONS
##==============================================================================

LoadParam() {

	## Check arguments
	if [ "$#" -eq 0 ]; then
		echo -e "No arguments provided."
		exit 1

	elif [ "$#" -eq 1 ]; then
		## Only 1 value provided: Assume its the key and the config file
		## has the default name "./config"
		KEY=$1
		FILE="./config"

	elif [ "$#" -eq 2 ]; then
		## Two values provided: Assume its the key and the config file
		KEY=$1
		FILE=$2

	elif [ "$#" -eq 3 ]; then
		## Three values provided: Assume its the key, a fallback value
		## if the key is not found, and the config file
		KEY=$1
		FALLBACK=$2
		FILE=$3

	else
		echo -e "Too many arguments provided"
        	exit 1
	fi



	## Check if file exists
	if [ ! -f "$FILE" ]; then
		echo "Configuration file $FILE does not exist."
		exit 1
	fi



	## Read configuration
	## Get lines containing the KEY at the beginning
	## Remove empty lines; comments (lines); trailing comments
	CONFIG=$(cat $FILE | grep -E "^$KEY\s" | sed '/^$/d;/^\#/d;/\#.*$/d;/\n/d')


    
	## Check number of lines
	NUM_VAR=$(echo -n "$CONFIG" | grep -c -E "^$KEY\s")
	if [ "$NUM_VAR" -eq 0 ]; then
		## Key not found in configuration:
		if [ -z "$FALLBACK" ]; then
			## No fallback defined. Tell user
			echo "$KEY parameter not found in $FILE"
			exit 1

		else
			## Otherwise, just warn the user and use fallback
			echo "$KEY parameter not found in $FILE. Restorting to fallback value: $FALLBACK"
			echo -n "$FALLBACK"
		fi

	elif [ "$NUM_VAR" -eq 1 ]; then
		## 1 Key-Value pair found: Strip value and return it
    		VALUE=$(echo "$CONFIG" | sed "s/$KEY\s*//")
    		echo -n "$VALUE"

	else
		echo "$KEY was found more than once in $FILE."
		exit 1
	fi   

}



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
