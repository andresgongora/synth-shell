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


##
##	DESCRIPTION:
##	This scripts prints to terminal a summary of your systems' status. This
##	includes basic information about the OS and the CPU, as well as
##	system resources, possible errors, and suspicions system activity.
##
##
##
##	CONFIGURATION:
##	Scroll down to the CUSTOMIZATION section to modify the logo and colors.
##
##
##
##
##	INSTALLATION:
##	Simply copy and paste this file into your ~/.bashrc file, or source
##	it externally (recommended).
##



##==============================================================================
##	COLOR DEFINITIONS
##==============================================================================

## REGULAR COLOROS
K='\033[0;30m'	# black
R='\033[0;31m'	# red
G='\033[0;32m'	# green
Y='\033[0;33m'	# yellow
B='\033[0;34m'	# blue
M='\033[0;35m'	# magenta
C='\033[0;36m'	# cyan
W='\033[0;37m'	# white
	
## BOLDFACE COLORS
BFK='\033[1;30m'
BFR='\033[1;31m'
BFG='\033[1;32m'
BFY='\033[1;33m'
BFB='\033[1;34m'
BFM='\033[1;35m'
BFC='\033[1;36m'
BFW='\033[1;37m'
BFO='\033[38;5;208m'	# Orange bold
BFT='\033[38;5;118m'	# Toxic green
	


NC='\033[0m'		# NO COLOR





##==============================================================================
##	CONFIGURATION
##==============================================================================

## IMPORT CONFIGURATION
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/../common/load_config.sh"
CONFIG_FILE="$DIR/config"


## LOGO
LOGO_01="${COLOR_LOGO}$(LoadParam "LOGO_01" "$CONFIG_FILE")${NC}"
LOGO_02=$(LoadParam "LOGO_02" "$CONFIG_FILE")
LOGO_03=$(LoadParam "LOGO_03" "$CONFIG_FILE")
LOGO_04=$(LoadParam "LOGO_04" "$CONFIG_FILE")
LOGO_05=$(LoadParam "LOGO_05" "$CONFIG_FILE")
LOGO_06=$(LoadParam "LOGO_06" "$CONFIG_FILE")
LOGO_07=$(LoadParam "LOGO_07" "$CONFIG_FILE")
LOGO_08=$(LoadParam "LOGO_08" "$CONFIG_FILE")
LOGO_09=$(LoadParam "LOGO_09" "$CONFIG_FILE")
LOGO_10=$(LoadParam "LOGO_10" "$CONFIG_FILE")
LOGO_11=$(LoadParam "LOGO_11" "$CONFIG_FILE")
LOGO_12=$(LoadParam "LOGO_12" "$CONFIG_FILE")
LOGO_13=$(LoadParam "LOGO_13" "$CONFIG_FILE")
LOGO_14=$(LoadParam "LOGO_14" "$CONFIG_FILE")
LOGO_PADDING=$(LoadParam "LOGO_PADDING" "$CONFIG_FILE")



## STATUS BARS
BAR_LENGTH=$(LoadParam "BAR_LENGTH" "$CONFIG_FILE")
CRIT_CPU_PERCENT=$(LoadParam "CRIT_CPU_PERCENT" "$CONFIG_FILE")
CRIT_MEM_PERCENT=$(LoadParam "CRIT_MEM_PERCENT" "$CONFIG_FILE")
CRIT_SWAP_PERCENT=$(LoadParam "CRIT_SWAP_PERCENT" "$CONFIG_FILE")
CRIT_HDD_PERCENT=$(LoadParam "CRIT_HDD_PERCENT" "$CONFIG_FILE")
MAX_DIGITS=$(LoadParam "MAX_DIGITS" "$CONFIG_FILE")


## SCRIPT LOCATIONS
COLOR_SCRIPT=$(LoadParam "COLOR_SCRIPT" "$CONFIG_FILE")


## TEXT COLOR
TXT_INFO=$(LoadParam "TXT_INFO" "$CONFIG_FILE")
TXT_HIGHLIGHT=$(LoadParam "TXT_HIGHLIGHT" "$CONFIG_FILE")
TXT_CRIT=$(LoadParam "TXT_CRIT" "$CONFIG_FILE")
TXT_DECO=$(LoadParam "TXT_DECO" "$CONFIG_FILE")
TXT_OK=$(LoadParam "TXT_OK" "$CONFIG_FILE")
TXT_ERR=$(LoadParam "TXT_ERR" "$CONFIG_FILE")
TXT_LOGO=$(LoadParam "TXT_LOGO" "$CONFIG_FILE")




##==============================================================================
##	GENERATE TEXT COLOR SEQUENCES
##==============================================================================

source $COLOR_SCRIPT
COLOR_INFO=$(getFormatCode $TXT_INFO)
COLOR_HL=$(getFormatCode $TXT_HIGHLIGHT)
COLOR_CRIT=$(getFormatCode $TXT_CRIT)
COLOR_DECO=$(getFormatCode $TXT_DECO)
COLOR_OK=$(getFormatCode $TXT_OK)
COLOR_ERR=$(getFormatCode $TXT_ERR)
COLOR_LOGO=$(getFormatCode $TXT_LOGO)



##==============================================================================
##	FUNCTIONS
##==============================================================================


##------------------------------------------------------------------------------
##
##	printBar(CURRENT, MAX, SIZE, CRIT_PERCENT)
##
##	Prints a bar that is filled depending on the relation between
##	CURRENT and MAX
##
##	1. CURRENT:     ammount to display on the bar.
##	2. MAX:         ammount that means that the bar should be printed
##	                completely full.
##	3. SIZE:        length of the bar as number of characters.
##	4. CRIT_PERCENT:between 0 and 100. Once the bar is over this percent, it
##			changes color.
##
printBar()
{
	CURRENT=$1
	MAX=$2
	SIZE=$3
	CRIT_PERCENT=$4


	## COMPUTE VARIABLES
	NUM_BARS=$(($SIZE * $CURRENT / $MAX))
	CRIT_NUM_BARS=$(($SIZE * $CRIT_PERCENT / 100))
	BAR_COLOR=$COLOR_OK
	if [ $NUM_BARS -gt $CRIT_NUM_BARS ]; then
		BAR_COLOR=$COLOR_CRIT
	fi
	
	## PRINT BAR
	printf "${COLOR_DECO}[${BAR_COLOR}"
	i=0
	while [ $i -lt $NUM_BARS ]; do
		printf "|"
		i=$[$i+1]
	done
	while [ $i -lt $SIZE ]; do
		printf " "
		i=$[$i+1]
	done
	printf "${COLOR_DECO}]${NC}"
}





##------------------------------------------------------------------------------
printLastLogins()
{
	printf "${COLOR_HL}\nLAST LOGINS:\n${COLOR_INFO}"
	last -iwa | head -n 4 | grep -v "reboot"
}




##------------------------------------------------------------------------------
printHeader()
{
	## GENERATE PROPER AMOUNT OF PAD
	i=0
	while [ $i -lt $MAX_DIGITS ]; do
		PAD="${PAD} "
		i=$[$i+1]
	done


	## LOGO
	#COLOR_LOGO_01=$($COLOR $LOGO_01 -c red)
	#echo -e $COLOR_LOGO_01
	COLOR_LOGO_01="${COLOR_LOGO}${LOGO_01}${NC}"
	COLOR_LOGO_02="${COLOR_LOGO}${LOGO_02}${NC}"
	COLOR_LOGO_03="${COLOR_LOGO}${LOGO_03}${NC}"
	COLOR_LOGO_04="${COLOR_LOGO}${LOGO_04}${NC}"
	COLOR_LOGO_05="${COLOR_LOGO}${LOGO_05}${NC}"
	COLOR_LOGO_06="${COLOR_LOGO}${LOGO_06}${NC}"
	COLOR_LOGO_07="${COLOR_LOGO}${LOGO_07}${NC}"
	COLOR_LOGO_08="${COLOR_LOGO}${LOGO_08}${NC}"
	COLOR_LOGO_09="${COLOR_LOGO}${LOGO_09}${NC}"
	COLOR_LOGO_10="${COLOR_LOGO}${LOGO_10}${NC}"
	COLOR_LOGO_11="${COLOR_LOGO}${LOGO_11}${NC}"
	COLOR_LOGO_12="${COLOR_LOGO}${LOGO_12}${NC}"
	COLOR_LOGO_13="${COLOR_LOGO}${LOGO_13}${NC}"
	COLOR_LOGO_14="${COLOR_LOGO}${LOGO_14}${NC}"


	## KERNEL INFO
	KERNEL=$(uname -r)
	KERNEL=$(echo -e "${COLOR_INFO}Kernel\t\t${COLOR_HL}$KERNEL${NC}")


	## SHELL
	SHELL=$(readlink /proc/$$/exe)
	SHELL=$(echo -e "${COLOR_INFO}Shell\t\t${COLOR_HL}$SHELL${NC}")


	## CPU INFO
	CPU=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -f1 -d "@")
	CPU="${CPU#*:}"
	CPU=$(echo "$CPU" | sed 's/  */ /g') # Trim spaces
	CPU=$(echo -e "${COLOR_INFO}CPU\t\t${COLOR_HL}${CPU:1}${NC}")


	## OS DISTRO NAME
	OS=$(cat /etc/*-release | grep PRETTY_NAME)
	OS="${OS#*=}"
	OS=$(echo "$OS" | sed 's/"//g') # remove " characters
	OS=$(echo -e "${COLOR_INFO}OS\t\t${COLOR_HL}$OS${NC}")


	## SYS DATE
	SYSDATE=$(date)
	SYSDATE=$(echo -e "${COLOR_INFO}Date\t\t${COLOR_HL}$SYSDATE${NC}")


	## LOGIN
	LOGIN=$(echo -e "${COLOR_INFO}Login\t\t${COLOR_HL}$USER@$HOSTNAME${NC}")


	## LOCAL IP
	LOCALIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
	LOCALIP=$(echo -e "${COLOR_INFO}Local IP\t${COLOR_HL}$LOCALIP${NC}")


	## EXTERNAL IP
	EXTERNALIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
	EXTERNALIP=$(echo -e "${COLOR_INFO}External IP\t${COLOR_HL}$EXTERNALIP${NC}")


	## SYSTEM CTL FAILED TO LOAD
	NUM_FAILED=$(systemctl --failed | head -c 1)
	if [ "$NUM_FAILED" -eq "0" ]; then
		SYSCTL=$(echo -e "${COLOR_INFO}SystemCTL\t${COLOR_HL}All services OK${NC}")
	else
		SYSCTL=$(echo -e "${COLOR_INFO}SystemCTL\t${COLOR_ERR}$NUM_FAILED services failed!${NC}")
	fi


	## CPU LOAD
	CPU_AVG=$(cat /proc/loadavg | awk '{avg_1m=($1)} END {printf "%3.0f", avg_1m}')
	CPU_MAX=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
	CPU_BAR=$(printBar $CPU_AVG $CPU_MAX $BAR_LENGTH $CRIT_CPU_PERCENT)
	CPU_PER=$(cat /proc/loadavg | awk '{printf "%3.0f\n",$1*100}')
	CPU_PER=$(($CPU_PER / $CPU_MAX))
	CPU_LOAD=$(echo -e "${COLOR_INFO}Sys load avg\t$CPU_BAR ${COLOR_HL}${CPU_PER:0:9} %%${NC}")


	## MEMORY
	MEM_INFO=$(free -m | head -n 2 | tail -n 1)
	MEM_CURRENT=$(echo "$MEM_INFO" | awk '{mem=($2-$7)} END {printf "%5.0f", mem}')
	MEM_MAX=$(echo "$MEM_INFO" | awk '{mem=($2)} END {printf "%1.0f", mem}')
	MEM_BAR=$(printBar $MEM_CURRENT $MEM_MAX $BAR_LENGTH $CRIT_MEM_PERCENT)
	MEM_MAX=$MEM_MAX$PAD
	MEM_USAGE=$(echo -e "${COLOR_INFO}Memory\t\t$MEM_BAR ${COLOR_HL}${MEM_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${MEM_MAX:0:${MAX_DIGITS}} MB${NC}")


	## SWAP
	SWAP_INFO=$(free -m | tail -n 1)
	SWAP_CURRENT=$(echo "$SWAP_INFO" | awk '{SWAP=($3)} END {printf "%5.0f", SWAP}')
	SWAP_MAX=$(echo "$SWAP_INFO" | awk '{SWAP=($2)} END {printf "%1.0f", SWAP}')
	SWAP_BAR=$(printBar $SWAP_CURRENT $SWAP_MAX $BAR_LENGTH $CRIT_SWAP_PERCENT)
	SWAP_MAX=$SWAP_MAX$PAD
	SWAP_USAGE=$(echo -e "${COLOR_INFO}Swap\t\t$SWAP_BAR ${COLOR_HL}${SWAP_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${SWAP_MAX:0:${MAX_DIGITS}} MB${NC}")


	## HDD /
	ROOT_CURRENT=$(df -BG / | grep "/" | awk '{key=($3)} END {printf "%5.0f", key}')
	ROOT_MAX=$(df -BG "/" | grep "/" | awk '{key=($2)} END {printf "%1.0f", key}')
	ROOT_BAR=$(printBar $ROOT_CURRENT $ROOT_MAX $BAR_LENGTH $CRIT_HDD_PERCENT)
	ROOT_MAX=$ROOT_MAX$PAD
	ROOT_USAGE=$(echo -e "${COLOR_INFO}Storage /\t$ROOT_BAR ${COLOR_HL}${ROOT_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${ROOT_MAX:0:${MAX_DIGITS}} GB${NC}")


	## HDD /home
	HOME_CURRENT=$(df -BG ~ | grep "/" | awk '{key=($3)} END {printf "%5.0f", key}')
	HOME_MAX=$(df -BG ~ | grep "/" | awk '{key=($2)} END {printf "%1.0f", key}')
	HOME_BAR=$(printBar $HOME_CURRENT $HOME_MAX $BAR_LENGTH $CRIT_HDD_PERCENT)
	HOME_MAX=$HOME_MAX$PAD
	HOME_USAGE=$(echo -e "${COLOR_INFO}Storage /home\t$HOME_BAR ${COLOR_HL}${HOME_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${HOME_MAX:0:${MAX_DIGITS}} GB${NC}")


	## CHECK TERMINAL SIZE
	## If the temrinal is not wide enough, override LOGO_PADDING
	WIDTH=$(tput cols)
	if [ "$WIDTH" -lt 90 ]; then
		LOGO_PADDING=""
	fi


	## PRINT HEADER WITH OVERALL STATUS REPORT
	printf "\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_01\t$OS\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_02\t$KERNEL\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_03\t$CPU\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_04\t$SHELL\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_05\t$SYSDATE\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_06\t$LOGIN\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_07\t$LOCALIP\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_08\t$EXTERNALIP\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_09\t$SYSCTL\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_10\t$CPU_LOAD\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_11\t$MEM_USAGE\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_12\t$SWAP_USAGE\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_13\t$ROOT_USAGE\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_14\t$HOME_USAGE\n\r\n\r"
}





##------------------------------------------------------------------------------
printSystemctl()
{
	NUM_FAILED=$(systemctl --failed | head -c 1)
	if [ "$NUM_FAILED" -ne "0" ]; then
		printf "\n\r${COLOR_HL}SYSTEMCTL STATUS: ${COLOR_ERR}At least one service failed to load!!${NC}\n\r"
		systemctl --failed
	fi
}





##------------------------------------------------------------------------------
printTop()
{
	if [ $CPU_PER -gt $CRIT_CPU_PERCENT ]; then
		TOP=$(top -b -d 5 -w 80| head -n 11)
		LOAD=$(echo "$TOP" | head -n 3 | tail -n 1)
		HEAD=$(echo "$TOP" | head -n 7 | tail -n 1)
		PROC=$(echo "$TOP" | tail -n 4 | grep -v "top")

		printf "\n\r${COLOR_HL}SYSTEM LOAD:${COLOR_INFO}  ${LOAD:8:35}${COLOR_HL}\n\r"
		echo "$HEAD"
		printf "${COLOR_INFO}$PROC${NC}"
	fi
}





##==============================================================================
##	MAIN
##==============================================================================

clear
printHeader
#printLastLogins
printSystemctl
printTop
exit 0

