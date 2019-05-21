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



## EYECANDY
alias grep='\grep --color=auto'
alias pacman='\pacman --color=auto'
alias tree='\tree --dirsfirst -C'
alias dmesg='\dmesg --color=auto --reltime --human --nopager --decode'
alias ls='~/Software/scripts/terminal/better-ls.sh'

if [ -f /usr/bin/prettyping ]; then
        alias ping='prettyping --nolegend' ## Replace ping with prettyping
fi




## IMPROVED BEHAVIOUR
alias sudo='\sudo '

if [ "$PS1" ]; then
	complete -cf sudo
fi

if [ -f /usr/bin/bat ]; then
        alias cat='bat' ## Replace cat with bat
fi






