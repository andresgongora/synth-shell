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
##	SED + RegEx	
##	===========
##
##	:a;N;$!ba               Append all lines into a single stream
##
##	s/[]\/$*.^|[]/\\&/g     Replace all "special" characters with a version
##	                        with an extra \ in front. But because we can
##	                        just write \, we have to write \\. Finally,
##				& becomes whatever character has ben matched.
##				As for the match, surrounding everything with
##				[] is a wildcard to match any.
##
##	s/[\n\t]$//g		Get rid of very last \n or \t (end of line)
##
##	s/[\n\t]/\\\\\\&/g      Replace any new-line or tab with a version
##	                        with extra dashes in front. These are necesary
##	                        because some get lost when the variable expands
##	                        into subsequent seds.
##


editTextFile()
{
	file=$1
	option=$2
	text=${@:3}


	## CHECK IF FILE EXISTS
	if [ ! -f "$file" ]; then
		echo "$file does not exists"
		exit 0
	elif [ ! -w "$file" ]; then
		echo "$file can not be written"
		exit 1
	fi


	## OPERATE ON FILE
	case $option in

	append)
		flat_text=$(echo -e $text | sed ':a;N;$!ba;s/[]\/$*.^|[]/\\&/g;s/[\n\t]$//g;s/[\n\t]/\\\\\\&/g;')
		found_text=$(sed -n ':a;N;$!ba;s/[\n\t]/\\&/g;/'"$flat_text"'/p' $file)
		if [ -z "$found_text" ]; then
			echo -e "$text\n" >> "$file"
		fi
		;;


	delete)
		flat_text=$(echo -e $text | sed ':a;N;$!ba;s/[]\/$*.^|[]/\\&/g;s/[\n\t]$//g;s/[\n\t]/\\\\\\&/g;')
		flat_file=$(sed ':a;N;$!ba;s/[\n\t]/\\&/g;s/'"$flat_text"'//g;s/\\\n/\n/g;s/\\\t/\t/g' $file)
		echo -e "$flat_file" > "$file"
		;;

	*)
		echo "Synopsis: editTextFile FILE [append|delete] [TEXT|VARIABLE]"
		;;
	esac
}


