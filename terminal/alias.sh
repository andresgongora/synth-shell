#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  |                             SYSTEM ALIASES                            |
##  |                                                                       |
##  | Copyright (c) 2019, Andres Gongora <mail@andresgongora.com>.          |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+




alias sudo='sudo '
alias grep='grep --color=auto'
alias ls='./better-ls.sh'
alias pacman='pacman --color=auto'




## GET LOCATION OF TREE COMMAND -> Check for all possible locations
if [ -f "/usr/bin/tree" ]; then
	TREE="/usr/bin/tree"
elif [ -f "/bin/tree" ]; then
	TREE="/bin/tree"
else
	echo "tree command not found"
fi
alias tree="$TREE --dirsfirst -C"





## GET LOCATION OF DMESG COMMAND -> Check for all possible locations
if [ -f "/usr/bin/dmesg" ]; then
	DMESG="/usr/bin/dmesg"
elif [ -f "/bin/dmesg" ]; then
	DMESG="/bin/dmesg"
else
	echo "dmesg command not found"
fi
alias dmesg="$DMESG --color=auto --reltime --human --nopager --decode"





