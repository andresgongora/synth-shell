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

	## CHECK IF CONFIGURATION FILE EXISTS
	local config_file=$1
	if [ -f $config_file ]; then

		## ITERATE THROUGH LINES IN CONFIGURATION FILE
		while IFS="" read -r p || [ -n "$p" ]
		do
			## REMOVE COMMENTS FROM LINE
			local trimmed_line=$(printf %b "$p" | sed '/^$/d;/^\#/d;s/\#.*$//g;/\n/d;')
			echo "$trimmed_line"
			## CONVERT LINE INTO SCRIPT PARAMETERS
			set -- $trimmed_line


			## LOAD CONFIG IF AT LEAST 2 PARAMETERS
			## Config-key-name and desired config value
			if [ "$#" -gt 1 ]; then

				## ASSING HUMAN READABLE NAMES
				local config_key_name=$1
				eval config_key_current_value=\$$config_key_name
				local config_param=$(echo "$trimmed_line" |\
				                     sed "s/$config_key_name\s*//" |\
				                     sed "s/^\"//;s/\"$//")

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





### EOF ###
