#!/usr/bin/env bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2024, Andres Gongora <mail@andresgongora.com>.     |
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



## TODO: add spacers between different days and sessions, with a beautiful header
## TODO: Fix line wraps. Maybe put everything inside a pager
## TODO: Format this script file



##==============================================================================
##	BETTER HISTORY
##==============================================================================

betterHistory()
{
	## Declare colors
	local blue="\033[0;34m"
	local nocolor="\033[0m"

	## Set configuration
	export HISTTIMEFORMAT=`echo -e ${blue}[%F %T] $nocolor `
	export HISTSIZE=100000
	export HISTFILESIZE=500000
	export HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.

	## Save multi-line commands as such (do not rearange in single line)
	shopt -s cmdhist
	shopt -s lithist
}
betterHistory


## BETTER COMMAND HISTORY (CTRL+r) >>>>>>>UNDER CONSTRUCTION<<<<<<<<<<<<<<<<<<<<
#if [ -f /usr/bin/fzf ]; then
#        alias preview="fzf --preview 'bat --color \"always\" {}'"
#        # add support for ctrl+o to open selected file in VS Code
#        export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"
#fi
