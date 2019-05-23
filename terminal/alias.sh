#!/bin/bash

##  +-----------------------------------+-----------------------------------+
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





##==============================================================================
##	SIMPLE COMMAND OPTIONS
##==============================================================================
alias grep='\grep --color=auto'
alias pacman='\pacman --color=auto'
alias tree='\tree --dirsfirst -C'
alias dmesg='\dmesg --color=auto --reltime --human --nopager --decode'
alias free='\free -mht'





##==============================================================================
##	COMMAND OVERRIDES
##==============================================================================
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


BETTER_LS_FILE="$DIR/better-ls.sh"
if [ -f $BETTER_LS_FILE ]; then
	chmod +x "$BETTER_LS_FILE"
        alias ls="$BETTER_LS_FILE"
fi

if [ -f /usr/bin/prettyping ]; then
        alias ping='prettyping --nolegend' ## Replace ping with prettyping
fi

if [ -f /usr/bin/bat ]; then
        alias cat='bat' ## Replace cat with bat
fi

BETTER_HISTORY_FILE="$DIR/better-history.sh"
if [ -f $BETTER_HISTORY_FILE ]; then
        source "$BETTER_HISTORY_FILE"
fi





##==============================================================================
##	BETTER SUDO
##==============================================================================

alias sudo='\sudo '

if [ "$PS1" ]; then
	complete -cf sudo
fi





### EOF ###
