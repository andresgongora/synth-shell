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
##	in completely separated file.
##
##	Nonetheless, to (i) enforce the user to write resilient scripts,
##	and to (ii) avoid unintentional leakage of variable into the users'
##	environment, this script only loads the configuration for variables
##	that exists and are not empty in its execution scope. This works both
##	for local and global variables
##
##
##
##	EXAMPLE:
##	Assume the file "/home/user/config" exists and contains:
##
##		## CONFIGURATION
##		user_number 7
##		user_string "Hello"
##
##	Then, its possible to write the following script:
##
##		## DECLARE VARIABLES AND SET DEFAULT VALUES
##		local my_var=1
##		MY_STR="Message"
##
##		## LOAD CONFIG
##		source load_config.sh
##		loadConfigFile "/home/user/config"
##
##		## USE VARIABLES
##		echo $my_var	# Will print 7 or fallback to 1
## 		echo $MY_STR	# Will print "Hello" or fallback to "Message"
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
##	TODO: Explain multilines
##



##==============================================================================
##  FUNCTION
##==============================================================================

##------------------------------------------------------------------------------
##
##	loadConfigFile
##
##	It will iterate through the configuration file searching for lines
##	containing key-parameter pairs. If there is a variable in the scripts
##	scope with the same name as the key, it will write to it the value
##	of the configuration parameter.
##
##	Arguments:
##	1. Path to configuration file
##
loadConfigFile() {

	## CHECK IF CONFIGURATION FILE EXISTS, EXIT IF NOT
	local config_file=$1
	if [ ! -f $config_file ]; then
		exit
	fi


	## ITERATE THROUGH LINES IN CONFIGURATION FILE
	## while not end of file, get line
	while IFS="" read -r p || [ -n "$p" ]
	do

		## REMOVE COMMENTS FROM LINE
		## /^$/d                Delete empty lines
		## /^[ \t]*\#/d         Delete lines that start as comment
		## s/[ \t][ \t]*\#.*//g Delete trailing comments
		## s/^[ \t]*//g         Delete preceding spaces and tabs
		## s/[ \t]*$//g         Delete trailing spaces and tabs
		local line=$(echo "$p" |\
		             sed -e '/^$/d;
		                     /^[ \t]*\#/d;
		                     s/[ \t][ \t]*\#.*//g;
		                     s/^[ \t]*//g;
		                     s/[ \t]*$//g')


		## CHECK IF MULTILINE
		## - Search for valid termination
		## - Signal multiline: tis is not used immediately, but
		##   at the end of the while loop.
		local line_end_trimmed=$(echo "$line" | sed -n 's/[ \t]*\\$//p')
		if [ -z "$line_end_trimmed" ]; then
			local is_multiline_next=false
		else
			local is_multiline_next=true
			local line=$line_end_trimmed
		fi


		## LOAD CONFIG IF AT LEAST 2 PARAMETERS
		## - Convert line into script parameters to test
		##   how many elements it contains.
		##   Notice that anything between quotes is converted to 'X'
		##   , as we only want to count them.
		## - Get key (should be first element)
		## - Get param (rest of line, when key deleted)
		set -- $( echo "$line" | sed -e 's/\\//g;s/".*"/X/g' )
		if [ ! -z "$line" ] && [ "$#" -gt 1 ]; then

			## GET KEY-PARAMETER PAIR
			## - Get key as first parameter
			## - Evaluate current value of key
			##   - Delete key name from line
			##   - Remove other auxiliar/optional characters
			local config_key_name=$1
			local config_param=$(echo "$line" |\
			                     sed -e "s/$config_key_name\s*//g" |\
			                     sed -e "s/^\"//g;s/\"$//g")


			## RE-ASSIGN CONFIG PARAMETER TO KEY
			## ONLY IF ALREADY DECLARED AND NOT EMPTY
			## This is meant to avoid loading config
			## parameters from the config file that
			## are not even used by the caller
			eval config_key_current_value=\$$config_key_name
			if [ ! -z "$config_key_current_value" ]; then

				## LOAD CONFIG PARAMETER
				export "${config_key_name}"="$config_param"
			fi


		## IF CONFIGURATION IS MULTILINE
		## - Get param continuation from current line
		## - Check if there is another extra line
		## - Append new param to old param
		elif [ "$#" -eq 1 ] && $is_multiline ; then

			## CHECK IF MULTILINE
			## - Search for valid termination
			## - Signal multiline
			local line_end_trimmed=$(echo $line |\
			                         sed -n 's/[ \t]*\\$//p')
			if [ -z "$line_end_trimmed" ]; then
				local multi_line=false
			else
				echo ":) $line_end_trimmed"
				local multi_line=true
				local line=$line_end_trimmed
			fi


			## GET PARAMETERS
			local config_param_old=$config_param
			local config_param=$(echo "$line" |\
			                     sed "s/^\"//g;s/\"$//g")


			## APPEND TO VARIABLE
			## Only if variable exists
			eval config_key_current_value=\$$config_key_name
			if [ ! -z "$config_key_current_value" ]; then
				export "${config_key_name}"="$config_key_current_value$config_param"
			fi
		fi


		## UPDATE MULTILINE INFORMATION FOR NEXT ITERATION
		local is_multiline=$is_multiline_next


	## END OF WHILE LOOP
	done < $config_file
}



### EOF ###
