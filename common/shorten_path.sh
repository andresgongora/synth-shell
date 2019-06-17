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
##	DESCRIPTION
##
##	This script takes a path name and shortens it.
##	- home is replaced by ~
##	- last folder in apth is never truncated
##
##
##	REFERENCES
##
##	Original source: WOLFMAN'S color bash promt
##	https://wiki.chakralinux.org/index.php?title=Color_Bash_Prompt#Wolfman.27s
##



##==============================================================================
##	FUNCTIONS
##==============================================================================

##------------------------------------------------------------------------------
##
shortenPath()
{
	## GET PARAMETERS
	local path=$1
	local max_length=$2
	local default_max_length=25
	local trunc_symbol=".."

	if   [ -z "$path" ]; then
		echo ""
		exit
	elif [ -z "$max_length" ]; then
		local max_length=$default_max_length
	fi



	## CLEANUP PATH
	## Replace HOME with ~ for the current user, similar to sed.
	local path=${path/#$HOME/\~}



	## TRUNCATE DIR IF NEEDED
	## - Get curred directory (last folder in path)
	## - Get max length, as the greater of etiher the (desired) max lenght
	##   and the length of the current dir. Dir never gets truncated.
	## - If path length > max_length 
	##	- Truncate the path to max_length
	##	- Clean off path fragments before first '/' (included)
	##	- Append "trunc_symbol", '/', and the clean path
	local dir=${path##*/}
	local dir_length=${#dir}
	local path_length=${#path}
	local print_length=$(( ( max_length < dir_length ) ? dir_length : max_length ))

	if [ $path_length -gt $print_length ]; then
		local offset=$(( $path_length - $print_length ))
		local truncated_path=${path:$offset}
		local clean_path=${truncated_path#*/}
		local short_path=${trunc_symbol}/${clean_path}
	else
		local short_path=$path
	fi



	## RETURN FINAL PATH
	echo $short_path
}




