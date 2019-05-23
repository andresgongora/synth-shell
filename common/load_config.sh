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
##	Very simple script to load configuration parameters into other scripts.
##	It can be used to retrieve all sorts of variables from a configuration
##	file, such that a script and its configuration parameters may be kept
##	in completely separated file
##
##
##
##
##	EXAMPLE:
##	Assume the file "/home/user/config" exists and contains:
##		user_number 7	#This is a configuration value##
##	Then, its possible to write the following script:
##		MY_VAR=$(LoadParam user_number "/home/user/config")
##		echo "$MY_VAR"##
##	which will print a 7 to terminal.
## 
##
##
##
##	FUNCTION USAGE
##	The core of this script is the function "LoadParam".
##	The moment this file is sourced into a script, said function should
##	become available. As for its parameters, it allows for three possible
##	modes of operation:
##
##	* LoadParam KEY:
##		This way of calling the function assumes that the invoking file
##		"./config" exists in the same folder as the script that
##		is loading the configuration. It only requires one parameter.
##
##		KEY:		The name of the variable inside of the conf file
##
##	* LoadParam KEY FILE:
##		KEY:		The name of the variable inside of the conf file
##		FILE:		The path to the conf file
##
##	* LoadParam KEY FALLBACK FILE:
##		This function call is more resilient, as it uses the value in
##		fallback if for whatever reason the KEY can not be located
##		inside the conf file, or if the conf file is missing.
##
##		KEY:		The name of the variable inside of the conf file
##		FILE:		The path to the conf file
##		FALLBACK:	Fallback value if KEY or FILE not found
##
##
##
##	CONFIGURATION FILES
##	* Each line is expected to contain a ingle KEY-VALUE pair.
##		* The first word in a line will be treated as the KEY.
##		  It may contain no spaces inside, but accepts all sort of
##		  punctuation marks if desired (e.g. .,-_).
##		* The configuration value follows the KEY after a space or tab.
##		  The value can be anything from a single integer to a string.
##	 	  It can contian any number of words, spaces and tabs,
##		  but not 'new line' characters
##
##	* Empty lines and comments (starting with #) are ignored.
##
##	* A KEY-VALUE pair might be followd by a comment (again, 
##	  starting with #) which will be trimmed before loading the data.
##	
##
##
##
##	ERROR HANDLING
##	This script-function returns the following exit codes:
##	* Exit code 0        Success
##	* Exit code 1        Could not load configuration
##



##==============================================================================
##  FUNCTION
##==============================================================================

## Halt if exit code not 0
#set -e

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
		## File does not exist
		if [ -z "$FALLBACK" ]; then
			## Also, no fallback value
			echo "Configuration file $FILE does not exist."
			exit 1
		else
			## Return fallback value instead, but warn user
			echo "Configuration file $FILE does not exist. Resorting for $KEY to fallback value: $FALLBACK"
			echo -n "$FALLBACK"
		fi
	fi



	## Read configuration
	## Get lines containing the KEY at the beginning
	## Remove empty lines; comments (lines); trailing comments
	CONFIG_LINE=$(cat $FILE | grep -E "^$KEY\s" | sed '/^$/d;/^\#/d;/\#.*$/d;/\n/d;')


    
	## Check number of lines
	NUM_VAR=$(echo -n "$CONFIG_LINE" | grep -c -E "^$KEY\s")
	if [ "$NUM_VAR" -eq 0 ]; then
		## Key not found in configuration:
		if [ -z "$FALLBACK" ]; then
			## No fallback defined. Tell user
			echo "$KEY parameter not found in $FILE"
			exit 1

		else
			## Otherwise, just warn the user and use fallback
			echo "$KEY parameter not found in $FILE. Resorting to fallback value: $FALLBACK"
			echo -n "$FALLBACK"
		fi

	elif [ "$NUM_VAR" -eq 1 ]; then
		## 1 Key-Value pair found: Strip value and return it
		## Remove " characters from the beguinning and end (only)
    		CONFIG_VALUE=$(echo "$CONFIG_LINE" | sed "s/$KEY\s*//" | sed "s/^\"//;s/\"$//")
    		echo -n "$CONFIG_VALUE"

	else
		echo "$KEY was found more than once in $FILE."
		exit 1
	fi   

}




##==============================================================================
##  FOR DEBUGGING ONLY
##==============================================================================


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


