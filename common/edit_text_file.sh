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


editTextFile()
{
	file=$1
	option=$2
	text=${@:3}

	case $option in

	append)
		flat_text=$(echo -e $text | sed -e ':a;N;$!ba;s/\\/\\\\/g;;s/\n/\\\\n/g;s/\t/\\\\t/g;s/\//\\\//g')
		echo $flat_text
		found_text=$(sed -n ":a;N;\$!ba;s/\n/\\\n/g;s/\t/\\\t/g;/${flat_text}/p" $file)
		if [ -z "$found_text" ]; then
			echo "Appending"
			echo -e "$text" >> "$file"
		fi
		;;


	delete)
		flat_text=$(echo -e $text | sed ":a;N;\$!ba;s/\n/\\\\\\\n/g;s/\t/\\\\\\\t/g")
		flat_file=$(sed ":a;N;\$!ba;s/\n/\\\n/g;s/\t/\\\t/g;s/${flat_text}//g" $file)
		echo -e "$flat_file" > "$file"
		;;

	*)
		echo "Synopsis: editTextFile FILE [append|delete] [TEXT|VARIABLE]"
		;;
	esac
}


hook=$(printf '%s'\
	             "line3\n"\
                     "\tline4\n"\
                     "line5//2\3")




editTextFile "./text.test" append "$hook"

