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
##	CONFIGURATION
##==============================================================================

## IMPORT EXTERNAL SCRIPTS
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/../common/load_config.sh"
source "$DIR/../common/color.sh"

CONFIG_FILE="$HOME/.config/scripts/terminal/status.config"
if [ ! -f $CONFIG_FILE ]; then
	CONFIG_FILE="$DIR/status.config"
fi	
unset DIR


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

unset CONFIG_FILE


##==============================================================================
##	GENERATE TEXT COLOR SEQUENCES
##==============================================================================
COLOR_INFO=$(getFormatCode $TXT_INFO)
COLOR_HL=$(getFormatCode $TXT_HIGHLIGHT)
COLOR_CRIT=$(getFormatCode $TXT_CRIT)
COLOR_DECO=$(getFormatCode $TXT_DECO)
COLOR_OK=$(getFormatCode $TXT_OK)
COLOR_ERR=$(getFormatCode $TXT_ERR)
COLOR_LOGO=$(getFormatCode $TXT_LOGO)
NC=$(getFormatCode -e reset)




##==============================================================================
##	OTHER
##==============================================================================

CPU_IS_CRIT=0



##==============================================================================
##	AUXILIARY FUNCTIONS
##==============================================================================

getOSInfo()
{
	local os=$(cat /etc/*-release | grep PRETTY_NAME)
	local os="${os#*=}"
	echo "$os" | sed 's/"//g' # remove " characters
}


getKernelInfo()
{
	uname -r
}


getCPUInfo()
{
	local cpu=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -f1 -d "@")
	echo "${cpu#*:}" | sed 's/  */ /g' | awk '$1=$1'
}


getShellInfo()
{
	readlink /proc/$$/exe
}


getSysDate()
{
	date +"%Y.%m.%d - %T"
}


getUserName()
{
	echo "$USER@$HOSTNAME"
}


getLocalIPv4()
{
	ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
}


getExternalIPv4()
{
	'wget' -t 1 -T 1 http://checkip.dyndns.org/ -O - -o /dev/null | cut -d: -f 2 | cut -d\< -f 1 | tr -d ' '
}





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
	local CURRENT=$1
	local MAX=$2
	local SIZE=$3
	local CRIT_PERCENT=$4


	## COMPUTE VARIABLES
	local NUM_BARS=$(($SIZE * $CURRENT / $MAX))
	local CRIT_NUM_BARS=$(($SIZE * $CRIT_PERCENT / 100))
	local BAR_COLOR=$COLOR_OK
	if [ $NUM_BARS -gt $CRIT_NUM_BARS ]; then
		local BAR_COLOR=$COLOR_CRIT
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
	local COLOR_LOGO_01="${COLOR_LOGO}${LOGO_01}${NC}"
	local COLOR_LOGO_02="${COLOR_LOGO}${LOGO_02}${NC}"
	local COLOR_LOGO_03="${COLOR_LOGO}${LOGO_03}${NC}"
	local COLOR_LOGO_04="${COLOR_LOGO}${LOGO_04}${NC}"
	local COLOR_LOGO_05="${COLOR_LOGO}${LOGO_05}${NC}"
	local COLOR_LOGO_06="${COLOR_LOGO}${LOGO_06}${NC}"
	local COLOR_LOGO_07="${COLOR_LOGO}${LOGO_07}${NC}"
	local COLOR_LOGO_08="${COLOR_LOGO}${LOGO_08}${NC}"
	local COLOR_LOGO_09="${COLOR_LOGO}${LOGO_09}${NC}"
	local COLOR_LOGO_10="${COLOR_LOGO}${LOGO_10}${NC}"
	local COLOR_LOGO_11="${COLOR_LOGO}${LOGO_11}${NC}"
	local COLOR_LOGO_12="${COLOR_LOGO}${LOGO_12}${NC}"
	local COLOR_LOGO_13="${COLOR_LOGO}${LOGO_13}${NC}"
	local COLOR_LOGO_14="${COLOR_LOGO}${LOGO_14}${NC}"


	## GET SYS SUMMARY 
	local os_info="${COLOR_INFO}OS\t\t${COLOR_HL}$(getOSInfo)${NC}"
	local kernel_info="${COLOR_INFO}Kernel\t\t${COLOR_HL}$(getKernelInfo)${NC}"
	local cpu_info="${COLOR_INFO}CPU\t\t${COLOR_HL}$(getCPUInfo)${NC}"
	local shell_info="${COLOR_INFO}Shell\t\t${COLOR_HL}$(getShellInfo)${NC}"
	local sys_date="${COLOR_INFO}Date\t\t${COLOR_HL}$(getSysDate)${NC}"
	local user_name="${COLOR_INFO}Login\t\t${COLOR_HL}$(getUserName)@$HOSTNAME${NC}"
	local local_ipv4="${COLOR_INFO}Local IP\t${COLOR_HL}$(getLocalIPv4)${NC}"
	local external_ipv4="${COLOR_INFO}External IP\t${COLOR_HL}$(getExternalIPv4)${NC}"




	## SYSTEM CTL FAILED TO LOAD
	local NUM_FAILED=$(systemctl --failed | head -c 1)
	if [ "$NUM_FAILED" -eq "0" ]; then
		local SYSCTL=$(echo -e "${COLOR_INFO}SystemCTL\t${COLOR_HL}All services OK${NC}")
	else
		local SYSCTL=$(echo -e "${COLOR_INFO}SystemCTL\t${COLOR_ERR}$NUM_FAILED services failed!${NC}")
	fi


	## CPU LOAD
	local CPU_AVG=$(cat /proc/loadavg | awk '{avg_1m=($1)} END {printf "%3.0f", avg_1m}')
	local CPU_MAX=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
	local CPU_BAR=$(printBar $CPU_AVG $CPU_MAX $BAR_LENGTH $CRIT_CPU_PERCENT)
	local CPU_PER=$(cat /proc/loadavg | awk '{printf "%3.0f\n",$1*100}')
	local CPU_PER=$(($CPU_PER / $CPU_MAX))
	local CPU_LOAD=$(echo -e "${COLOR_INFO}Sys load avg\t$CPU_BAR ${COLOR_HL}${CPU_PER:0:9} %%${NC}")
	if [ $CPU_PER -gt $CRIT_CPU_PERCENT ]; then
		CPU_IS_CRIT=1
		echo "critical"
	fi



	## MEMORY
	local MEM_INFO=$(free -m | head -n 2 | tail -n 1)
	local MEM_CURRENT=$(echo "$MEM_INFO" | awk '{mem=($2-$7)} END {printf mem}')
	while [ ${#MEM_CURRENT} -lt $MAX_DIGITS ]
	do
  		local MEM_CURRENT=" $MEM_CURRENT"
	done
	local MEM_MAX=$(echo "$MEM_INFO" | awk '{mem=($2)} END {printf mem}')
	while [ ${#MEM_MAX} -lt $MAX_DIGITS ]
	do
  		local MEM_MAX="$MEM_MAX "
	done
	local MEM_BAR=$(printBar $MEM_CURRENT $MEM_MAX $BAR_LENGTH $CRIT_MEM_PERCENT)
	local MEM_MAX=$MEM_MAX$PAD
	local MEM_USAGE=$(echo -e "${COLOR_INFO}Memory\t\t$MEM_BAR ${COLOR_HL}${MEM_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${MEM_MAX:0:${MAX_DIGITS}} MB${NC}")


	## SWAP
	local SWAP_INFO=$(free -m | tail -n 1)
	local SWAP_CURRENT=$(echo "$SWAP_INFO" | awk '{SWAP=($3)} END {printf SWAP}')
	while [ ${#SWAP_CURRENT} -lt $MAX_DIGITS ]
	do
  		local SWAP_CURRENT=" $SWAP_CURRENT"
	done
	local SWAP_MAX=$(echo "$SWAP_INFO" | awk '{SWAP=($2)} END {printf SWAP}')
	while [ ${#SWAP_CURRENT} -lt $MAX_DIGITS ]
	do
  		local SWAP_CURRENT=" $SWAP_CURRENT"
	done
	local SWAP_BAR=$(printBar $SWAP_CURRENT $SWAP_MAX $BAR_LENGTH $CRIT_SWAP_PERCENT)
	local SWAP_MAX=$SWAP_MAX$PAD
	local SWAP_USAGE=$(echo -e "${COLOR_INFO}Swap\t\t$SWAP_BAR ${COLOR_HL}${SWAP_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${SWAP_MAX:0:${MAX_DIGITS}} MB${NC}")


	## HDD /
	local ROOT_CURRENT=$(df -B1G / | grep "/" | awk '{key=($3)} END {printf key}')
	while [ ${#ROOT_CURRENT} -lt $MAX_DIGITS ]
	do
  		local ROOT_CURRENT=" $ROOT_CURRENT"
	done
	local ROOT_MAX=$(df -B1G "/" | grep "/" | awk '{key=($2)} END {printf key}')
	while [ ${#ROOT_CURRENT} -lt $MAX_DIGITS ]
	do
  		local ROOT_CURRENT=" $ROOT_CURRENT"
	done
	local ROOT_BAR=$(printBar $ROOT_CURRENT $ROOT_MAX $BAR_LENGTH $CRIT_HDD_PERCENT)
	local ROOT_MAX=$ROOT_MAX$PAD
	local ROOT_USAGE=$(echo -e "${COLOR_INFO}Storage /\t$ROOT_BAR ${COLOR_HL}${ROOT_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${ROOT_MAX:0:${MAX_DIGITS}} GB${NC}")


	## HDD /home
	local HOME_CURRENT=$(df -B1G ~ | grep "/" | awk '{key=($3)} END {printf key}')
	while [ ${#HOME_CURRENT} -lt $MAX_DIGITS ]
	do
  		local HOME_CURRENT=" $HOME_CURRENT"
	done
	local HOME_MAX=$(df -B1G ~ | grep "/" | awk '{key=($2)} END {printf key}')
	while [ ${#HOME_CURRENT} -lt $MAX_DIGITS ]
	do
  		local HOME_CURRENT=" $HOME_CURRENT"
	done
	local HOME_BAR=$(printBar $HOME_CURRENT $HOME_MAX $BAR_LENGTH $CRIT_HDD_PERCENT)
	local HOME_MAX=$HOME_MAX$PAD
	local HOME_USAGE=$(echo -e "${COLOR_INFO}Storage /home\t$HOME_BAR ${COLOR_HL}${HOME_CURRENT:0:${MAX_DIGITS}}${COLOR_INFO}/${COLOR_HL}${HOME_MAX:0:${MAX_DIGITS}} GB${NC}")


	## CHECK TERMINAL SIZE
	## If the temrinal is not wide enough, override LOGO_PADDING
	local WIDTH=$(tput cols)
	if [ "$WIDTH" -lt 90 ]; then
		local LOGO_PADDING=""
	fi


	## PRINT HEADER WITH OVERALL STATUS REPORT
	printf "\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_01\t$os_info\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_02\t$kernel_info\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_03\t$cpu_info\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_04\t$shell_info\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_05\t$sys_date\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_06\t$user_name\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_07\t$local_ipv4\n\r"
	printf "$LOGO_PADDING$COLOR_LOGO_08\t$external_ipv4\n\r"
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
	local NUM_FAILED=$(systemctl --failed | head -c 1)
	if [ "$NUM_FAILED" -ne "0" ]; then
		printf "\n\r${COLOR_HL}SYSTEMCTL STATUS: ${COLOR_ERR}At least one service failed to load!!${NC}\n\r"
		systemctl --failed
	fi
}





##------------------------------------------------------------------------------
printTop()
{
	if [ $CPU_IS_CRIT -eq 1 ]; then
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
#exit 0

