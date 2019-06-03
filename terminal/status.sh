#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019, Andres Gongora <mail@andresgongora.com>.          |
##  | Copyright (c) 2019, Sami Olmari <sami@olmari.fi>.                     |
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
##	INSTALLATION:
##	Simply copy and paste this file into your ~/.bashrc file, or source
##	it externally (recommended).
##




##==============================================================================
##	AUXILIARY FUNCTIONS
##==============================================================================

getOSInfo()
{
	if [ -f /etc/os-release ]; then
		local result=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /etc/os-release)
	elif [ -f /usr/lib/os-release ]; then
		local result=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /usr/lib/os-release)
	else
		local result="N/A"	
	fi

	printf "$result"
}


getKernelInfo()
{
	uname -r
}


getCPUInfo()
{
	sed -nE '0,/^\s*model name/s/^\s*model name\s*:\s*(.*\S)/\1/p' /proc/cpuinfo|sed 's/\s*@.*//'
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


##------------------------------------------------------------------------------
##
##	getLocalIPv4()
##
##  Looks up and returns local IPv4-address.
##
##  Tries first program found.
##
##  !!! NOTE: Still needs to figure out how to look for IP address that has default gateway
##  !!! attached to related interface, otherwise this returns list of IPv4's if there are many
##  !!! TODO: Simplify?
##
getLocalIPv4()
{
	if which ip > /dev/null; then
		local result=$($(which ip) -family inet addr show | grep -oP '^\s*inet\s+(addr:?\s*)?\K(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))' | sed '/127.0.0.1/d;:a;N;$!ba;s/\n/,/g')
	elif which ifconfig > /dev/null; then
		local result=$($(which ifconfig) | grep -oP '^\s*inet\s+(addr:?\s*)?\K(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))' | sed '/127.0.0.1/d;:a;N;$!ba;s/\n/,/g')
	else
		local result="Error"
	fi

	## Returns "N/A" if actual query result is empty, and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}


##------------------------------------------------------------------------------
##
##	getExternalIPv4()
##
##	Makes an query to internet-server and returns public IPv4-address
##
##	Tries first program found,
##	program search ordering is based on timed tests, fastest to slowest.
##
##	DNS-based queries are always faster, around real time 0.1 seconds.
##	URL-queries are relatively slow, around real time 1 seconds.
##
getExternalIPv4()
{
	if which dig > /dev/null; then
		local result=$($(which dig) TXT -4 +short o-o.myaddr.l.google.com @ns1.google.com | awk -F\" '{print $2}')
	elif which nslookup > /dev/null; then
		local result=$($(which nslookup) -q=txt o-o.myaddr.l.google.com 216.239.32.10 | awk -F \" 'BEGIN{RS="\r\n"}{print $2}END{RS="\r\n"}')
	elif which curl > /dev/null; then
		local result=$($(which curl) -s https://api.ipify.org)
	elif which wget > /dev/null; then
		local result=$($(which wget) -q -O - https://api.ipify.org)
	else
		local result="Error"
	fi

	## Returns "N/A" if actual query result is empty, and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}


##------------------------------------------------------------------------------
##
##	getLocalIPv6()
##
##	Looks up and returns local IPv6-address.
##
##	Tries first program found.
##
##	!!! NOTE: Still needs to figure out how to look for IP address that has default gateway
##	!!! attached to related interface, otherwise this returns list of IPv6's if there are many
##
getLocalIPv6()
{
	if which ip > /dev/null; then
		local result=$($(which ip) -family inet6 addr show | grep -oP '^\s*inet6\s+(addr:?\s*)?\K((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?' | sed '/::1/d;:a;N;$!ba;s/\n/,/g')
	elif which ifconfig > /dev/null; then
		local result=$($(which ifconfig) | grep -oP '^\s*inet6\s+(addr:?\s*)?\K((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?' | sed '/::1/d;:a;N;$!ba;s/\n/,/g')
	else
		local result="Error"
	fi

	## Returns "N/A" if actual query result is empty, and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}


##------------------------------------------------------------------------------
##
##	getExternalIPv6()
##
##	Makes an query to internet-server and returns public IPv6-address
##
##	Tries first program found,
##	program search ordering is based on timed tests, fastest to slowest.
##
##	DNS-based queries are always faster, around real time 0.1 seconds.
##	URL-queries are relatively slow, around real time 1 seconds.
##
getExternalIPv6()
{
	if which dig > /dev/null; then
		local result=$($(which dig) TXT -6 +short o-o.myaddr.l.google.com @ns1.google.com | awk -F\" '{print $2}')
	elif which nslookup > /dev/null; then
		local result=$($(which nslookup) -q=txt o-o.myaddr.l.google.com 2001:4860:4802:32::a | awk -F \" 'BEGIN{RS="\r\n"}{print $2}END{RS="\r\n"}')
	elif which curl > /dev/null; then
		local result=$($(which curl) -s https://api6.ipify.org)
	elif which wget > /dev/null; then
		local result=$($(which wget) -q -O - https://api6.ipify.org)
	else
		local result="Error"
	fi

	## Returns "N/A" if actual query result is empty, and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}


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
	local current=$1
	local max=$2
	local size=$3
	local crit_percent=$4



	## COMPUTE VARIABLES
	local num_bars=$(($size * $current / $max))
	if [ $num_bars -gt $size ]; then
		num_bars=$size
	fi
	local crit_num_bars=$(($size * $crit_percent / 100))
	local bar_color=$fc_ok
	if [ $num_bars -gt $crit_num_bars ]; then
		local bar_color=$fc_crit
	fi



	## PRINT BAR
	printf "${fc_deco}[${bar_color}"
	i=0
	while [ $i -lt $num_bars ]; do
		printf "|"
		i=$[$i+1]
	done
	while [ $i -lt $size ]; do
		printf " "
		i=$[$i+1]
	done
	printf "${fc_deco}]${fc_none}"
}





##==============================================================================
##	STATUS COMPOSITION
##==============================================================================


printHeader()
{
	## GENERATE PROPER AMOUNT OF PAD
	i=0
	while [ $i -lt $max_digits ]; do
		PAD="${PAD} "
		i=$[$i+1]
	done



	## LOGO
	local formatted_logo_01="${fc_logo}${logo_01}${fc_none}"
	local formatted_logo_02="${fc_logo}${logo_02}${fc_none}"
	local formatted_logo_03="${fc_logo}${logo_03}${fc_none}"
	local formatted_logo_04="${fc_logo}${logo_04}${fc_none}"
	local formatted_logo_05="${fc_logo}${logo_05}${fc_none}"
	local formatted_logo_06="${fc_logo}${logo_06}${fc_none}"
	local formatted_logo_07="${fc_logo}${logo_07}${fc_none}"
	local formatted_logo_08="${fc_logo}${logo_08}${fc_none}"
	local formatted_logo_09="${fc_logo}${logo_09}${fc_none}"
	local formatted_logo_10="${fc_logo}${logo_10}${fc_none}"
	local formatted_logo_11="${fc_logo}${logo_11}${fc_none}"
	local formatted_logo_12="${fc_logo}${logo_12}${fc_none}"
	local formatted_logo_13="${fc_logo}${logo_13}${fc_none}"
	local formatted_logo_14="${fc_logo}${logo_14}${fc_none}"



	## GET SYS SUMMARY
	local os_info="${fc_info}OS\t\t${fc_highlight}$(getOSInfo)${fc_none}"
	local kernel_info="${fc_info}Kernel\t\t${fc_highlight}$(getKernelInfo)${fc_none}"
	local cpu_info="${fc_info}CPU\t\t${fc_highlight}$(getCPUInfo)${fc_none}"
	local shell_info="${fc_info}Shell\t\t${fc_highlight}$(getShellInfo)${fc_none}"
	local sys_date="${fc_info}Date\t\t${fc_highlight}$(getSysDate)${fc_none}"
	local user_name="${fc_info}Login\t\t${fc_highlight}$(getUserName)${fc_none}"
	local local_ipv4="${fc_info}Local IPv4\t${fc_highlight}$(getLocalIPv4)${fc_none}"
	local external_ipv4="${fc_info}External IPv4\t${fc_highlight}$(getExternalIPv4)${fc_none}"



	#### UGLY FROM HERE ON #################################################


	## SYSTEM CTL FAILED TO LOAD
	local NUM_FAILED=$(systemctl --failed | head -c 1)
	if [ "$NUM_FAILED" -eq "0" ]; then
		local SYSCTL=$(echo -e "${fc_info}SystemCTL\t${fc_highlight}All services OK${fc_none}")
	else
		local SYSCTL=$(echo -e "${fc_info}SystemCTL\t${fc_error}$NUM_FAILED services failed!${fc_none}")
	fi


	## CPU LOAD
	local CPU_AVG=$(awk '{avg_1m=($1)} END {printf "%3.0f", avg_1m}' /proc/loadavg)
	local CPU_MAX=$(nproc --all)
	local CPU_BAR=$(printBar $CPU_AVG $CPU_MAX $bar_length $crit_cpu_percent)
	local CPU_PER=$(awk '{printf "%3.0f\n",$1*100}' /proc/loadavg)
	local CPU_PER=$(($CPU_PER / $CPU_MAX))
	local CPU_LOAD=$(echo -e "${fc_info}Sys load avg\t$CPU_BAR ${fc_highlight}${CPU_PER:0:9} %%${fc_none}")
	if [ $CPU_PER -gt $crit_cpu_percent ]; then
		cpu_is_crit=true
	fi



	## MEMORY
	local MEM_INFO=$('free' -m | head -n 2 | tail -n 1)
	local MEM_CURRENT=$(echo "$MEM_INFO" | awk '{mem=($2-$7)} END {printf mem}')
	while [ ${#MEM_CURRENT} -lt $max_digits ]
	do
  		local MEM_CURRENT=" $MEM_CURRENT"
	done
	local MEM_MAX=$(echo "$MEM_INFO" | awk '{mem=($2)} END {printf mem}')
	while [ ${#MEM_MAX} -lt $max_digits ]
	do
  		local MEM_MAX="$MEM_MAX "
	done
	local MEM_BAR=$(printBar $MEM_CURRENT $MEM_MAX $bar_length $crit_mem_percent)
	local MEM_MAX=$MEM_MAX$PAD
	local MEM_USAGE=$(echo -e "${fc_info}Memory\t\t$MEM_BAR ${fc_highlight}${MEM_CURRENT:0:${max_digits}}${fc_info}/${fc_highlight}${MEM_MAX:0:${max_digits}} MB${fc_none}")


	## SWAP
	local SWAP_INFO=$('free' -m | tail -n 1)
	local SWAP_CURRENT=$(echo "$SWAP_INFO" | awk '{SWAP=($3)} END {printf SWAP}')
	while [ ${#SWAP_CURRENT} -lt $max_digits ]
	do
  		local SWAP_CURRENT=" $SWAP_CURRENT"
	done
	local SWAP_MAX=$(echo "$SWAP_INFO" | awk '{SWAP=($2)} END {printf SWAP}')
	if [ "$SWAP_MAX" -eq "0" ]; then
		local SWAP_USAGE=$(echo -e "${fc_info}Swap\t\t${fc_highlight}N/A${fc_none}")
	else
		while [ ${#SWAP_CURRENT} -lt $max_digits ]
		do
	  		local SWAP_CURRENT=" $SWAP_CURRENT"
		done
		local SWAP_BAR=$(printBar $SWAP_CURRENT $SWAP_MAX $bar_length $crit_swap_percent)
		local SWAP_MAX=$SWAP_MAX$PAD
		local SWAP_USAGE=$(echo -e "${fc_info}Swap\t\t$SWAP_BAR ${fc_highlight}${SWAP_CURRENT:0:${max_digits}}${fc_info}/${fc_highlight}${SWAP_MAX:0:${max_digits}} MB${fc_none}")
	fi


	## HDD /
	local ROOT_CURRENT=$(df -B1G / | grep "/" | awk '{key=($3)} END {printf key}')
	while [ ${#ROOT_CURRENT} -lt $max_digits ]
	do
  		local ROOT_CURRENT=" $ROOT_CURRENT"
	done
	local ROOT_MAX=$(df -B1G / | grep "/" | awk '{key=($2)} END {printf key}')
	while [ ${#ROOT_CURRENT} -lt $max_digits ]
	do
  		local ROOT_CURRENT=" $ROOT_CURRENT"
	done
	local ROOT_BAR=$(printBar $ROOT_CURRENT $ROOT_MAX $bar_length $crit_hdd_percent)
	local ROOT_MAX=$ROOT_MAX$PAD
	local ROOT_USAGE=$(echo -e "${fc_info}Storage /\t$ROOT_BAR ${fc_highlight}${ROOT_CURRENT:0:${max_digits}}${fc_info}/${fc_highlight}${ROOT_MAX:0:${max_digits}} GB${fc_none}")


	## HDD /home
	local HOME_CURRENT=$(df -B1G ~ | grep "/" | awk '{key=($3)} END {printf key}')
	while [ ${#HOME_CURRENT} -lt $max_digits ]
	do
  		local HOME_CURRENT=" $HOME_CURRENT"
	done
	local HOME_MAX=$(df -B1G ~ | grep "/" | awk '{key=($2)} END {printf key}')
	while [ ${#HOME_CURRENT} -lt $max_digits ]
	do
  		local HOME_CURRENT=" $HOME_CURRENT"
	done
	local HOME_BAR=$(printBar $HOME_CURRENT $HOME_MAX $bar_length $crit_hdd_percent)
	local HOME_MAX=$HOME_MAX$PAD
	local HOME_USAGE=$(echo -e "${fc_info}Storage /home\t$HOME_BAR ${fc_highlight}${HOME_CURRENT:0:${max_digits}}${fc_info}/${fc_highlight}${HOME_MAX:0:${max_digits}} GB${fc_none}")



	## PRINT HEADER WITH OVERALL STATUS REPORT
	printf '\033[?7l'	# Disable line wrap -> Crop instead
	printf "\n\r"
	printf "${logo_padding}${formatted_logo_01}\t${os_info}\n\r"
	printf "${logo_padding}${formatted_logo_02}\t${kernel_info}\n\r"
	printf "${logo_padding}${formatted_logo_03}\t${cpu_info}\n\r"
	printf "${logo_padding}${formatted_logo_04}\t${shell_info}\n\r"
	printf "${logo_padding}${formatted_logo_05}\t${sys_date}\n\r"
	printf "${logo_padding}${formatted_logo_06}\t${user_name}\n\r"
	printf "${logo_padding}${formatted_logo_07}\t${local_ipv4}\n\r"
	printf "${logo_padding}${formatted_logo_08}\t${external_ipv4}\n\r"
	printf "${logo_padding}${formatted_logo_09}\t${SYSCTL}\n\r"
	printf "${logo_padding}${formatted_logo_10}\t${CPU_LOAD}\n\r"
	printf "${logo_padding}${formatted_logo_11}\t${MEM_USAGE}\n\r"
	printf "${logo_padding}${formatted_logo_12}\t${SWAP_USAGE}\n\r"
	printf "${logo_padding}${formatted_logo_13}\t${ROOT_USAGE}\n\r"
	printf "${logo_padding}${formatted_logo_14}\t${HOME_USAGE}\n\r\n\r"
	printf '\033[?7h'	# Re-enable line wrap
}





printLastLogins()
{
	## DO NOTHING FOR NOW -> This is all commented out intentionally. Printing logins should only be done under different conditions
	# 1. User configurable set to always on
	# 2. If the IP/terminal is very diffefrent from usual
	# 3. Other anomalies...
	if false; then
		printf "${fc_highlight}\nLAST LOGINS:\n${fc_info}"
		last -iwa | head -n 4 | grep -v "reboot"
	fi
}





printSystemctl()
{
	local NUM_FAILED=$(systemctl --failed | head -c 1)
	if [ "$NUM_FAILED" -ne "0" ]; then
		printf "\n\r${fc_highlight}SYSTEMCTL STATUS: ${fc_error}At least one service failed to load!!${fc_none}\n\r"
		systemctl --failed
	fi
}





printTop()
{
	if $cpu_is_crit; then
		local top=$('nice' 'top' -b -w 80 -d 0.1 -1 | head -n 11)
		local load=$(echo "${top}" | head -n 3 | tail -n 1)
		local head=$(echo "${top}" | head -n 7 | tail -n 1)
		local proc=$(echo "${top}" | tail -n 4 | grep -v "top")

		printf "\n\r${fc_highlight}SYSTEM LOAD:${fc_info}  ${load:8:35}${fc_highlight}\n\r"
		echo "$head"
		printf "${fc_info}${proc}${fc_none}"
	fi
}





##==============================================================================
##	STATUS
##==============================================================================

status()
{
	## INCLUDE EXTERNAL DEPENDENCIES
	## Only if the functions are not available
	## If not, search in `common` folder
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	if [ "$(type -t loadConfigFile)" != 'function' ];
	then
		source "$dir/../common/load_config.sh"
	fi

	if [ "$(type -t getFormatCode)" != 'function' ];
	then
		source "$dir/../common/color.sh"
	fi



	## SCRIPT WIDE VARIABLES
	local cpu_is_crit=false



	## DEFAULT CONFIGURATION
	## WARNING! Do not edit directly, use configuration files instead

	local logo_01="        -oydNMMMMNdyo-        "
	local logo_02="     -yNMMMMMMMMMMMMMMNy-     "
	local logo_03="   .hMMMMMMmhsooshmMMMMMMh.   "
	local logo_04="  :NMMMMmo.        .omMMMMN:  "
	local logo_05=" -NMMMMs    -+ss+-    sMMMMN- "
	local logo_06=" hMMMMs   -mMMMMMMm-   sMMMMh "
	local logo_07="'MMMMM.  'NMMMMMMMMN'  .MMMMM'"
	local logo_08="'MMMMM.  'NMMMMMMMMN'   yMMMM'"
	local logo_09=" hMMMMs   -mMMMMMMMMy.   -yMh "
	local logo_10=" -NMMMMs    -+ss+yMMMMy.   -. "
	local logo_11="  :NMMMMmo.       .yMMMMy.    "
	local logo_12="   .hMMMMMMmhsoo-   .yMMMy    "
	local logo_13="     -yNMMMMMMMMMy-   .o-     "
	local logo_14="        -oydNMMMMNd/          "
	local logo_padding=""

	local format_info="-c white"
	local format_highlight="-c blue  -e bold"
	local format_crit="-c 208   -e bold"
	local format_deco="-c white -e bold"
	local format_ok="-c blue  -e bold"
	local format_error="-c 208   -e bold -e blink"
	local format_logo="-c blue -e bold"

	local bar_length=15
	local crit_cpu_percent=50
	local crit_mem_percent=75
	local crit_swap_percent=25
	local crit_hdd_percent=80
	local max_digits=5



	## LOAD USER CONFIGURATION
	local user_config_file="$HOME/.config/scripts/status.config"
	local sys_config_file="/etc/andresgongora/scripts/status.config"
	if [ -f $user_config_file ]; then
		loadConfigFile $user_config_file
	elif [ -f $sys_config_file ]; then
		loadConfigFile $sys_config_file
	fi


	## COLOR AND TEXT FORMAL CODE
	local fc_info=$(getFormatCode $format_info)
	local fc_highlight=$(getFormatCode $format_highlight)
	local fc_crit=$(getFormatCode $format_crit)
	local fc_deco=$(getFormatCode $format_deco)
	local fc_ok=$(getFormatCode $format_ok)
	local fc_error=$(getFormatCode $format_error)
	local fc_logo=$(getFormatCode $format_logo)
	local fc_none=$(getFormatCode -e reset)



	## PRINT STATUS ELEMENTS
	clear
	printHeader
	printLastLogins
	printSystemctl
	printTop
}


## CALL MAIN FUNCTION
status




### EOF ###
