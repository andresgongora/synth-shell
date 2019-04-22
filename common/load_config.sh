#!/bin/bash

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	| Copyright (c) 2019, Andres Gongora <mail@andresgongora.com>.          |
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
##	DESCRIPTION:
##	This script updates your "PS1" environment variable to display colors.
##	Addicitionally, it also shortens the name of your current part to maximum
##	25 characters, which is quite useful when working in deeply nested folders.
##
##
##
##	INSTALLATION:
##	Copy this script to your home folder and rename it to ".fancy-bash-promt.sh"
##	Run this command from any terminal: 
##		echo "source ~/.fancy-bash-promt.sh" >> ~/.bashrc
##
##	Alternatively, copy the content of this file into your .bashrc file
##
##
##
##	FUNCTIONS:
##
##	* bash_prompt_command()
##	  This function takes your current working directory and stores a shortened
##	  version in the variable "NEW_PWD".
##
##	* format_font()
##	  A small helper function to generate color formating codes from simple
##	  number codes (defined below as local variables for convenience).
##
##	* bash_prompt()
##	  This function colorizes the bash promt. The exact color scheme can be
##	  configured here. The structure of the function is as follows:
##		1. A. Definition of available colors for 16 bits.
##		1. B. Definition of some colors for 256 bits (add your own).
##		2. Configuration >> EDIT YOUR PROMT HERE<<.
##		4. Generation of color codes.
##		5. Generation of window title (some terminal expect the first
##		   part of $PS1 to be the window title)
##		6. Formating of the bash promt ($PS1).
##
##	* Main script body:	
##	  It calls the adequate helper functions to colorize your promt and sets
##	  a hook to regenerate your working directory "NEW_PWD" when you change it.
## 

#Exit code 0        Success
#Exit code 1        General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations
#Exit code 2        Misuse of shell builtins (according to Bash documentation)        Example: empty_function() {}


##==============================================================================
##  FUNCTIONS
##==============================================================================

get_config() {

    ## Check arguments
    if [ "$#" -eq 0 ]; then
       echo -e "No arguments provided."
       exit 1
    elif [ "$#" -eq 1 ]; then
        KEY=$1
        FILE=$0
    elif [ "$#" -eq 2 ]; then
        KEY=$1
        FILE=$2
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
    ## Remove empty lines; comments (lines); trailing comments
    ## Get lines containing the KEY at the beginning
    CONFIG=$(cat $FILE | sed '/^$/d;/^\#/d;/\#.*$/d' | grep -E "^$KEY\s")

    
    ## Check number of lines
    NUM_VAR=$(echo "$CONFIG" | wc -l)
    if [ "$NUM_VAR" -lt 1 ]; then
        echo "$KEY parameter not found in $FILE."
        exit 1
    elif [ "$NUM_VAR" -gt 1 ]; then
        echo "$KEY was found more than once in $FILE."
        exit 1
    fi


    ## Strip configuration value and return it
    VALUE=$(echo "$CONFIG" | sed "s/$KEY\s*//")
    echo "$VALUE"
}



NAME=$(get_config NAME2)
echo "$NAME"

NAME2 pepe
