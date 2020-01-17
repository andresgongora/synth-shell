#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2020, Andres Gongora <mail@andresgongora.com>.     |
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
##	This script prints to terminal a summary of your system's status. This
##	includes basic information about the OS and the CPU, as well as
##	system resources, possible errors, and suspicions system activity.
##
##



status()
{


##==============================================================================
##	AUXILIARY FUNCTIONS
##==============================================================================

##------------------------------------------------------------------------------
##
##	getLocalIPv6()
##
##	Looks up and returns local IPv6-address.
##	Test for the presence of several programs in case one is missing.
##	Program search ordering is based on timed tests, fastest to slowest.
##
##	!!! NOTE: Still need to figure out how to look for IP address that
##	!!!       have a default gateway attached to related interface,
##	!!!       otherwise this returns a list of IPv6's if there are many.
##
getLocalIPv6()
{



	## GREP REGGEX EXPRESSION TO RETRIEVE IP STRINGS
	##
	## The following string is intuitive and easy to read, but only parses
	## strings that look like IPs without checking their value. For instance,
	## it does NOT check value ranges of IPv6
	##
	## grep explanation:
	## -oP				only return matching parts of a line, and use perl regex
	## \s*inet6\s+			any-spaces "inet6" at-least-1-space
	## (addr:?\s*)?			optionally, followed by addr or addr:
	## \K				everything until here, omit
	## (){1,8}			repeat block at least 1 time, up to 8
	## ([0-9abcdef]){0,4}:*		up to 4 chars from [] followed by :
	##
	#local grep_reggex='\s*inet6\s+(addr:?\s*)?\K(([0-9abcdef]){0,4}:*){1,8}'
	##
	## The following string, on the other hand, is harder to read and
	## understand, but is MUCH safer, as it ensures that the IP
	## fulfills some criteria.
	local grep_reggex='^\s*inet6\s+(addr:?\s*)?\K((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?'


	if   ( which ip > /dev/null 2>&1 ); then
		local result=$($(which ip) -family inet6 addr show |\
		grep -oP "$grep_reggex" |\
		sed '/::1/d;:a;N;$!ba;s/\n/,/g')

	elif ( which ifconfig > /dev/null 2>&1 ); then
		local result=$($(which ifconfig) |\
		grep -oP "$grep_reggex" |\
		sed '/::1/d;:a;N;$!ba;s/\n/,/g')

	else
		local result="Error"
	fi


	## Returns "N/A" if actual query result is empty,
	## and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}



##------------------------------------------------------------------------------
##
##	getExternalIPv6()
##
##	Makes an query to internet-server and returns public IPv6-address.
##	Tests for the presence of several programs in case one is missing.
##	Program search ordering is based on timed tests, fastest to slowest.
##	DNS-based queries are always faster, ~0.1 seconds.
##	URL-queries are relatively slow, ~1 seconds.
##
getExternalIPv6()
{
	if   ( which dig > /dev/null 2>&1 ); then
		local result=$($(which dig) TXT -6 +short o-o.myaddr.l.google.com @ns1.google.com |\
		               awk -F\" '{print $2}')

	elif ( which nslookup > /dev/nul 2>&1 ); then
		local result=$($(which nslookup) -q=txt o-o.myaddr.l.google.com 2001:4860:4802:32::a |\
		               awk -F \" 'BEGIN{RS="\r\n"}{print $2}END{RS="\r\n"}')

	elif ( which curl > /dev/null 2>&1 ); then
		local result=$($(which curl) -s https://api6.ipify.org)

	elif ( which wget > /dev/null 2>&1 ); then
		local result=$($(which wget) -q -O - https://api6.ipify.org)

	else
		local result="Error"
	fi


	## Returns "N/A" if actual query result is empty,
	## and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}






##==============================================================================
##	INFO AND MONITOR PRINTING HELPERS
##==============================================================================

##------------------------------------------------------------------------------
##
##	printInfo(LABEL, VALUE)
##	Print a formatted message comprised of a label and a value
##	1. LABEL will be printed with info color
##	2. VALUE will be printed with highlight color
##
printInfo()
{
	label=$1
	value=$2
	pad=$info_label_width

	printf "${fc_info}%-${pad}s${fc_highlight}${value}${fc_none}\n" "$label"
}



##------------------------------------------------------------------------------
##
##	printBar(CURRENT, MAX, SIZE, COLOR, COLOR)
##
##	Prints a bar that is filled depending on the relation between
##	CURRENT and MAX
##
##	1. CURRENT:       amount to display on the bar.
##	2. MAX:           amount that means that the bar should be printed
##	                  completely full.
##	3. SIZE:          length of the bar as number of characters.
##	4. BRACKET_COLOR: Color for the brackets. May be empty for not colored.
##	5. BAR_COLOR:	  Color for the bars. May be empty for not colored.
##
printBar()
{
	## VARIABLES
	local current=$1
	local max=$2
	local size=$3
	local bracket_color=$4
	local bar_color=$5


	## COMPUTE VARIABLES
	local num_bars=$(bc <<< "$size * $current / $max")
	if [ $num_bars -gt $size ]; then
		num_bars=$size
	fi


	## PRINT BAR
	## - Opening bracket
	## - Full bars
	## - Remaining empty space
	## - Closing bracket
	printf "${bracket_color}[${bar_color}"
	i=0
	while [ $i -lt $num_bars ]; do
		printf "|"
		i=$[$i+1]
	done
	while [ $i -lt $size ]; do
		printf " "
		i=$[$i+1]
	done
	printf "${bracket_color}]${fc_none}"
}



##------------------------------------------------------------------------------
##
##	printFraction(NUMERATOR, DENOMINATOR, PADDING_DIGITS, UNITS)
##
##	Prints a color-formatted fraction with padding to reach MAX_DIGITS.
##
##	1. NUMERATOR:      first shown number
##	2. DENOMINATOR:    second shown number
##	3. PADDING_DIGITS: determines the minimum length of NUMERATOR and
##	                   DENOMINATOR. If they have less digits than this,
##	                   then extra spaces are appended for padding.
##	4. UNITS: a string that is attached to the end of the fraction,
##	          meant to include optional units (e.g. MB) for display purposes.
##	          If "none", no units are displayed.
##	5,6,7. COLORS: of decoration (/), numbers, and units.
##
printFraction()
{
	local a=$1
	local b=$2
	local padding=$3
	local units=$4
	local deco_color=$5
	local num_color=$6
	local units_color=$7

	if [ $units == "none" ]; then local units=""; fi

	printf "${num_color}%${padding}s" $a
	printf "${deco_color}/"
	printf "${num_color}%-${padding}s" $b
	printf "${units_color} ${units}${fc_none}"
}



##------------------------------------------------------------------------------
##
##	printMonitor()
##
##	Prints a resource utilization monitor, comprised of a bar and a fraction.
##
##	1. CURRENT: current resource utilization (e.g. occupied GB in HDD)
##	2. MAX: max resource utilization (e.g. HDD size)
##	3. CRIT_PERCENT: point at which to warn the user (e.g. 80 for 80%)
##	4. PRINT_AS_PERCENTAGE: whether to print a simple percentage after
##	   the utilization bar (true), or to print a fraction (false).
##	5. UNITS: units of the resource, for display purposes only. This are
##	   not shown if PRINT_AS_PERCENTAGE=true, but must be set nonetheless.
##	6. LABEL: A description of the resource that will be printed in front
##	   of the utilization bar.
##
printMonitor()
{
	## CHECK EXTERNAL CONFIGURATION
	if [ -z $bar_num_digits ]; then exit 1; fi
	if [ -z $fc_deco        ]; then exit 1; fi
	if [ -z $fc_ok          ]; then exit 1; fi
	if [ -z $fc_info        ]; then exit 1; fi
	if [ -z $fc_crit        ]; then exit 1; fi


	## VARIABLES
	local current=$1
	local max=$2
	local crit_percent=$3
	local print_as_percentage=$4
	local units=$5
	local label=${@:6}
	local pad=$info_label_width


	## CHECK VARIABLES
	## If max is empty, assign 0
	## If crit percent is empty, assign 100
	## If crit_percent > 100, assign 100
	if [ -z $max ]; then local max=0; fi
	if [ -z $crit_percent ]; then local local crit_percent=100; fi
	if [ "$crit_percent" -gt 100 ]; then local crit_percent=100; fi


	## COMPUTE PERCENT
	## If max=0, then avoid division
	## Otherwise compute as usual
	if [ "$max" -eq 0 ]; then
		local percent=100
	else
		local percent=$(bc <<< "$current*100/$max")
	fi


	## SET COLORS DEPENDING ON LOAD
	local fc_bar_1=$fc_deco
	local fc_bar_2=$fc_ok
	local fc_txt_1=$fc_info
	local fc_txt_2=$fc_ok
	local fc_txt_3=$fc_ok
	if   [ $percent -gt 99 ]; then
		local fc_bar_2=$fc_error
		local fc_txt_2=$fc_crit
	elif [ $percent -gt $crit_percent ]; then
		local fc_bar_2=$fc_crit
		local fc_txt_2=$fc_crit
	fi


	## PRINT BAR
	printf "${fc_info}%-${pad}s" "$label"
	printBar $current $max $bar_length $fc_bar_1 $fc_bar_2


	## PRINT NUMERIC VALUE
	if $print_as_percentage; then
		printf "${fc_txt_2}%${bar_num_digits}s${fc_txt_1} %%%%${fc_none}" $percent
	else
		printf " "
		printFraction $current $max $bar_num_digits $units \
		              $fc_txt_1 $fc_txt_2 $fc_txt_3
	fi
}





##==============================================================================
##	INFO AND MONITOR MESSAGES
##==============================================================================

printInfoOS()
{
	if   [ -f /etc/os-release ]; then
		local os_name=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /etc/os-release)
	elif [ -f /usr/lib/os-release ]; then
		local os_name=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /usr/lib/os-release)
	else
		local os_name=$(uname -sr)
	fi

	printInfo "OS" "$os_name"
}



##------------------------------------------------------------------------------
##
printInfoKernel()
{
	local kernel=$(uname -r)
	printInfo "Kernel" "$kernel"
}



##------------------------------------------------------------------------------
##
printInfoCPU()
{
	## Get first instance of "model name" in /proc/cpuinfo, pipe into 'sed'
	## s/model name\s*:\s*//  remove "model name : " and accompanying spaces
	## s/\s*@.*//             remove anything from "@" onwards
	## s/(R)//                remove "(R)"
	## s/(TM)//               remove "(TM)"
	## s/CPU//                remove "CPU"
	## s/\s\s\+/ /            clean up double spaces (replace by single space)
	## p                      print final output
	local cpu=$(grep -m 1 "model name" /proc/cpuinfo |\
	            sed -n 's/model name\s*:\s*//;
	                    s/\s*@.*//;
	                    s/(R)//;
	                    s/(TM)//;
	                    s/CPU//;
	                    s/\s\s\+/ /;
	                    p')

	printInfo "CPU" "$cpu"
}



##------------------------------------------------------------------------------
##
printInfoGPU()
{
	## DETECT GPU(s)set	
	local gpu_id=$(lspci | grep ' VGA ' | cut -d" " -f 1)

	## FOR ALL DETECTED IDs
	## Get the GPU name, but trim all buzzwords away
	echo -e "$gpu_id" | while read line ; do
	   	local gpu=$(lspci  -v -s "$line" |\
		            head -n 1 |\
		            sed 's/^.*: //g;s/(.*$//g;
		                 s/Corporation//g;
		                 s/Core Processor//g;
		                 s/Series//g;
		                 s/Chipset//g;
		                 s/Graphics//g;
		                 s/processor//g;
		                 s/Controller//g;
		                 s/Family//g;
		                 s/Inc.//g;
		                 s/,//g;
		                 s/Technology//g;
		                 s/Mobility/M/g;
		                 s/Advanced Micro Devices/AMD/g;
		                 s/\[AMD\/ATI\]/ATI/g;
		                 s/Integrated Graphics Controller/HD Graphics/g;
		                 s/Integrated Controller/IC/g;
		                 s/  */ /g'
		           )

		## If GPU name still to long, remove anything between []
		if [ "${#gpu}" -gt 30 ]; then
			local gpu=$(echo "$gpu" | sed 's/\[.*\]//g' )
		fi


		printInfo "GPU" "$gpu"
	done

}


##------------------------------------------------------------------------------
##
printInfoShell()
{
	local shell=$(readlink /proc/$$/exe)
	printInfo "Shell" "$shell"
}



##------------------------------------------------------------------------------
##
printInfoDate()
{
	local sys_date=$(date +"$date_format")
	printInfo "Date" "$sys_date"
}



##------------------------------------------------------------------------------
##
printInfoUptime()
{
	local uptime=$(uptime -p | sed 's/^[^,]*up *//g')
	printInfo "Uptime" "$uptime"
}



##------------------------------------------------------------------------------
##
printInfoUser()
{
	printInfo "User" "$USER@$HOSTNAME"
}



##------------------------------------------------------------------------------
##
printInfoNumLoggedIn()
{
	## -n	silent
	## 	replace everything with content of the group inside \( \)
	## p	print
	num_users=$(uptime |\
	            sed -n 's/.*\([[0-9:]]* users\).*/\1/p')

	printInfo "Logged in" "$num_users"
}



##------------------------------------------------------------------------------
##
printInfoNameLoggedIn()
{
	## who			See who is logged in
	## awk '{print $1;}'	First word of each line
	## sort -u		Sort and remove duplicates
	local name_users=$(who | awk '{print $1;}' | sort -u)

	printInfo "Logged in" "$name_users"
}



##------------------------------------------------------------------------------
##
##	getLocalIPv4()
##
##	Looks up and returns local IPv4-address.
##	Tries first program found.
##	!!! NOTE: Still needs to figure out how to look for IP address that
##	!!!       have a default gateway attached to related interface,
##	!!!       otherwise this returns list of IPv4's if there are many
##
printInfoLocalIPv4()
{
	## GREP REGEX EXPRESSION TO RETRIEVE IP STRINGS
	##
	## The following string is intuitive and easy to read, but only parses
	## strings that look like IPs, without checking their value. For instance,
	## it does NOT check whether the IP bytes are [0-255], rather it
	## accepts values from [0-999] as valid.
	##
	## grep explanation:
	## -oP				only return matching parts of a line, and use perl regex
	## \s*inet\s+			any-spaces "inet6" at-least-1-space
	## (addr:?\s*)?			optionally, followed by addr or addr:
	## \K				everything until here, omit
	## (){4}			repeat block at least 1 time, up to 8
	## ([0-9]){1,4}:*		1 to 3 integers [0-9] followed by "."
	##
	#local grep_reggex='^\s*inet\s+(addr:?\s*)?\K(([0-9]){1,3}\.*){4}'
	##
	## The following string, on the other hand, is harder to read and
	## understand, but is MUCH safer, as it ensure that the IP
	## fulfills some criteria.
	local grep_reggex='^\s*inet\s+(addr:?\s*)?\K(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'


	if   ( which ip > /dev/null 2>&1 ); then
		local ip=$($(which ip) -family inet addr show |\
		           grep -oP "$grep_reggex" |\
		           sed '/127.0.0.1/d;:a;N;$!ba;s/\n/,/g')

	elif ( which ifconfig > /dev/null 2>&1 ); then
		local ip=$($(which ifconfig) |\
		           grep -oP "$grep_reggex"|\
		           sed '/127.0.0.1/d;:a;N;$!ba;s/\n/,/g')
	else
		local result="Error"
	fi


	## FIX IP FORMAT
	## Add extra space after commas for readibility
	local result=$(echo "$result" | sed 's/,/, /g')


	## PRINT LOCAL IPs
	## Returns "N/A" if actual query result is empty,
	## and returns "Error" if no programs found
	[ $ip ] || local ip="N/A"
	printInfo "Local IPv4" "$ip"
}



##------------------------------------------------------------------------------
##
##	getExternalIPv4()
##
##	Makes a query to internet-server and returns public IPv4-address.
##	Test for the presence of several programs in case one is missing.
##	Program search ordering is based on timed tests, fastest to slowest.
##	DNS-based queries are always faster, ~0.1 seconds.
##	URL-queries are relatively slow, ~1 seconds.
##
printInfoExternalIPv4()
{
	if   ( which dig > /dev/null 2>&1 ); then
		local ip=$(dig +time=3 +tries=1 TXT -4 +short \
		           o-o.myaddr.l.google.com @ns1.google.com |\
		           awk -F\" '{print $2}')

	elif ( which nslookup > /dev/null 2>&1 ); then
		local ip=$(nslookup -timeout=3 -q=txt \
		           o-o.myaddr.l.google.com 216.239.32.10 |\
		           awk -F \" 'BEGIN{RS="\r\n"}{print $2}END{RS="\r\n"}')

	elif ( which curl > /dev/null 2>&1 ); then
		local ip=$(curl -s https://api.ipify.org)

	elif ( which wget > /dev/null 2>&1 ); then
		local ip=$(wget -q -O - https://api.ipify.org)
	else
		local result="Error"
	fi


	## Returns "N/A" if actual query result is empty,
	## and returns "Error" if no programs found
	[ $ip ] || local ip="N/A"
	printInfo "External IPv4" "$ip"
}



##------------------------------------------------------------------------------
##
printInfoSystemctl()
{
	local systcl_num_failed=$(systemctl --failed |\
	                          grep "loaded units listed" |\
	                          head -c 1)

	if   [ "$systcl_num_failed" -eq "0" ]; then
		local sysctl="All services OK"
	elif [ "$systcl_num_failed" -eq "1" ]; then
		local sysctl="${fc_error}1 service failed!${fc_none}"
	else
		local sysctl="${fc_error}$systcl_num_failed services failed!${fc_none}"
	fi

	printInfo "Services" "$sysctl"
}



##------------------------------------------------------------------------------
##
printInfoColorpaletteSmall()
{
	local char="▀▀"

	local palette=$(printf '%s'\
	"$(formatText "$char" -c black -b dark-gray)"\
	"$(formatText "$char" -c red -b light-red)"\
	"$(formatText "$char" -c green -b light-green)"\
	"$(formatText "$char" -c yellow -b light-yellow)"\
	"$(formatText "$char" -c blue -b light-blue)"\
	"$(formatText "$char" -c magenta -b light-magenta)"\
	"$(formatText "$char" -c cyan -b light-cyan)"\
	"$(formatText "$char" -c light-gray -b white)")

	printInfo "Color palette" "$palette"
}



##------------------------------------------------------------------------------
##
printInfoColorpaletteFancy()
{
	local palette_top=$(printf '%s'\
		"$(formatText "▄" -c dark-gray)$(formatText "▄" -c dark-gray -b black)$(formatText "█" -c black) "\
		"$(formatText "▄" -c light-red)$(formatText "▄" -c light-red -b red)$(formatText "█" -c red) "\
		"$(formatText "▄" -c light-green)$(formatText "▄" -c light-green -b green)$(formatText "█" -c green) "\
		"$(formatText "▄" -c light-yellow)$(formatText "▄" -c light-yellow -b yellow)$(formatText "█" -c yellow) "\
		"$(formatText "▄" -c light-blue)$(formatText "▄" -c light-blue -b blue)$(formatText "█" -c blue) "\
		"$(formatText "▄" -c light-magenta)$(formatText "▄" -c light-magenta -b magenta)$(formatText "█" -c magenta) "\
		"$(formatText "▄" -c light-cyan)$(formatText "▄" -c light-cyan -b cyan)$(formatText "█" -c cyan) "\
		"$(formatText "▄" -c white)$(formatText "▄" -c white -b light-gray)$(formatText "█" -c light-gray) ")

	local palette_bot=$(printf '%s'\
		"$(formatText "██" -c dark-gray)$(formatText "▀" -c black) "\
		"$(formatText "██" -c light-red)$(formatText "▀" -c red) "\
		"$(formatText "██" -c light-green)$(formatText "▀" -c green) "\
		"$(formatText "██" -c light-yellow)$(formatText "▀" -c yellow) "\
		"$(formatText "██" -c light-blue)$(formatText "▀" -c blue) "\
		"$(formatText "██" -c light-magenta)$(formatText "▀" -c magenta) "\
		"$(formatText "██" -c light-cyan)$(formatText "▀" -c cyan) "\
		"$(formatText "██" -c white)$(formatText "▀" -c light-gray) ")

	printInfo "" "$palette_top"
	printInfo "Color palette" "$palette_bot"
}



##------------------------------------------------------------------------------
##
printInfoSpacer()
{
	printInfo "" ""
}



##------------------------------------------------------------------------------
##
printInfoCPUUtilization()
{
	local avg_load=$(uptime | sed 's/^.*load average: //g')	
	printInfo "Sys load" "$avg_load"
}



##------------------------------------------------------------------------------
##
printInfoCPUTemp()
{
	if ( which sensors > /dev/null 2>&1 ); then

		## GET VALUES
		local temp_line=$(sensors |\
		                  grep Core |\
		                  head -n 1 |\
		                  sed 's/^.*:[ \t]*//g;s/[\(\),]//g')
		local units=$(echo $temp_line |\
		              sed -n 's/.*\(°[[CF]]*\).*/\1/p')
		local current=$(echo $temp_line |\
		                sed -n 's/^.*+\(.*\)°[[CF]]*[ \t]*h.*/\1/p')
		local high=$(echo $temp_line |\
		             sed -n 's/^.*high = +\(.*\)°[[CF]]*[ \t]*c.*/\1/p')
		local max=$(echo $temp_line |\
		            sed -n 's/^.*crit = +\(.*\)°[[CF]]*[ \t]*.*/\1/p')


		## COMPOSE MESSAGE
		if   (( $(echo "$current < $high" |bc -l) )); then 
			local temp="$current$units";
		elif (( $(echo "$current < $max" |bc -l) )); then 
			local temp="$fc_crit$current$units";
		else                             
			local temp="$fc_error$current$units";
		fi

		
		## PRINT MESSAGE
		printInfo "CPU temp" "$temp"
	else
		printInfo "CPU temp" "lm-sensors not installed"
	fi

	
}



##------------------------------------------------------------------------------
##
printMonitorCPU()
{
	local message="Sys load avg"
	local units="none"
	local current=$(awk '{avg_1m=($1)} END {printf "%3.2f", avg_1m}' /proc/loadavg)
	local max=$(nproc --all)


	local as_percentage=$1
	if [ -z "$as_percentage" ]; then local as_percentage=false; fi


	printMonitor $current $max $crit_cpu_percent \
	             $as_percentage $units $message
}



##------------------------------------------------------------------------------
##
printMonitorRAM()
{
	local message="Memory"
	local units="MB"
	local mem_info=$('free' -m | head -n 2 | tail -n 1)
	local current=$(echo "$mem_info" | awk '{mem=($2-$7)} END {printf mem}')
	local max=$(echo "$mem_info" | awk '{mem=($2)} END {printf mem}')


	local as_percentage=$1
	if [ -z "$as_percentage" ]; then local as_percentage=false; fi


	printMonitor $current $max $crit_ram_percent \
	             $as_percentage $units $message
}



##------------------------------------------------------------------------------
##
printMonitorSwap()
{
	local message="Swap"
	local units="MB"
	local as_percentage=$1
	if [ -z "$as_percentage" ]; then local as_percentage=false; fi


	## CHECK IF SYSTEM HAS SWAP
	## Count number of lines in /proc/swaps, excluding the header (-1)
	## This is not fool-proof, but if num_swap_devs>=1, there should be swap
	local num_swap_devs=$(($(wc -l /proc/swaps | awk '{print $1;}') -1))
	
	if [ "$num_swap_devs" -lt 1 ]; then ## NO SWAP
		

		local pad=${info_label_width}
		printf "${fc_info}%-${pad}s${fc_highlight}N/A${fc_none}" "${message}"
	
	else ## HAS SWAP	
		local swap_info=$('free' -m | tail -n 1)
		local current=$(echo "$swap_info" |\
		                awk '{SWAP=($3)} END {printf SWAP}')
		local max=$(echo "$swap_info" |\
		            awk '{SWAP=($2)} END {printf SWAP}')

		printMonitor $current $max $crit_swap_percent \
		             $as_percentage $units $message
	fi
}



##------------------------------------------------------------------------------
##
printMonitorHDD()
{
	local as_percentage=$1
	if [ -z "$as_percentage" ]; then local as_percentage=false; fi


	local message="Storage /"
	local units="GB"
	local current=$(df -B1G / | grep "/" |awk '{key=($3)} END {printf key}')
	local max=$(df -B1G / | grep "/" | awk '{key=($2)} END {printf key}')


	printMonitor $current $max $crit_hdd_percent \
	             $as_percentage $units $message
}



##------------------------------------------------------------------------------
##
printMonitorHome()
{
	local as_percentage=$1
	if [ -z "$as_percentage" ]; then local as_percentage=false; fi


	local message="Storage /home"
	local units="GB"
	local current=$(df -B1G ~ | grep "/" |awk '{key=($3)} END {printf key}')
	local max=$(df -B1G ~ | grep "/" | awk '{key=($2)} END {printf key}')


	printMonitor $current $max $crit_home_percent \
	             $as_percentage $units $message
}



##------------------------------------------------------------------------------
##
printMonitorCPUTemp()
{
	if ( which sensors > /dev/null 2>&1 ); then

		## GET VALUES
		local temp_line=$(sensors |\
		                  grep Core |\
		                  head -n 1 |\
		                  sed 's/^.*:[ \t]*//g;s/[\(\),]//g')
		local units=$(echo $temp_line |\
		              sed -n 's/.*\(°[[CF]]*\).*/\1/p' )
		local current=$(echo $temp_line |\
		                sed -n 's/^.*+\(.*\)°[[CF]]*[ \t]*h.*/\1/p' )
		local high=$(echo $temp_line |\
		            sed -n 's/^.*high = +\(.*\)°[[CF]]*[ \t]*c.*/\1/p' )
		local max=$(echo $temp_line |\
		              sed -n 's/^.*crit = +\(.*\)°[[CF]]*[ \t]*.*/\1/p' )
		local crit_percent=$(bc <<< "$high*100/$max")

		
		## PRINT MONITOR
		printMonitor $current $max $crit_percent \
	        	     false $units "CPU temp"
	else
		printInfo "CPU temp" "lm-sensors not installed"
	fi
}





##==============================================================================
##	STATUS INFO COMPOSITION
##==============================================================================

##------------------------------------------------------------------------------
##
printStatusInfo()
{
	## HELPER FUNCTION
	statusSwitch()
	{
		case $1 in
		## 	INFO (TEXT ONLY)
		##	NAME		FUNCTION
			OS)		printInfoOS;;
			KERNEL)		printInfoKernel;;
			CPU)		printInfoCPU;;
			GPU)		printInfoGPU;;
			SHELL)		printInfoShell;;
			DATE)		printInfoDate;;
			UPTIME)		printInfoUptime;;
			USER)		printInfoUser;;
			NUMLOGGED)	printInfoNumLoggedIn;;
			NAMELOGGED)	printInfoNameLoggedIn;;
			LOCALIPV4)	printInfoLocalIPv4;;
			EXTERNALIPV4)	printInfoExternalIPv4;;
			SERVICES)	printInfoSystemctl;;
			PALETTE_SMALL)	printInfoColorpaletteSmall;;
			PALETTE)	printInfoColorpaletteFancy;;
			SPACER)		printInfoSpacer;;
			CPUUTILIZATION)	printInfoCPUUtilization;;
			CPUTEMP)	printInfoCPUTemp;;

		## 	USAGE MONITORS (BARS)
		##	NAME		FUNCTION		AS %
			SYSLOAD_MON)	printMonitorCPU;;
			SYSLOAD_MON%)	printMonitorCPU		true;;
			MEMORY_MON)	printMonitorRAM;;
			MEMORY_MON%)	printMonitorRAM		true;;
			SWAP_MON)	printMonitorSwap;;
			SWAP_MON%)	printMonitorSwap 	true;;
			HDDROOT_MON)	printMonitorHDD;;
			HDDROOT_MON%)	printMonitorHDD 	true;;
			HDDHOME_MON)	printMonitorHome;;
			HDDHOME_MON%)	printMonitorHome 	true;;
			CPUTEMP_MON)	printMonitorCPUTemp;;

			*)		printInfo "Unknown" "Check your config";;
		esac
	}


	## ASSEMBLE INFO PANE
	local status_info=""
	for key in $print_info; do
		if [ -z "$status_info" ]; then
			local status_info="$(statusSwitch $key)"
		else
			local status_info="${status_info}\n$(statusSwitch $key)"
		fi
	done
	printf "${status_info}\n"
}






##==============================================================================
##	PRINT
##==============================================================================

##------------------------------------------------------------------------------
##
printHeader()
{
	## GET ELEMENTS TO PRINT
	local logo=$(echo "$fc_logo$logo$fc_none")
	local info=$(printStatusInfo)


	## GET ELEMENT SIZES
	local term_cols=$(getTerminalNumCols)
	local logo_cols=$(getTextNumCols "$logo")
	local info_cols=$(getTextNumCols "$info")


	## PRINT TOP SPACER
	if $clear_before_print; then clear; fi
	if $print_extra_new_line_top; then echo ""; fi


	## PRINT ONLY WHAT FITS IN THE TERMINAL
	if [ $(( $logo_cols + $info_cols )) -lt $term_cols ]; then
		if $print_logo_right ; then
			printTwoElementsSideBySide "$info" "$logo" "$print_cols_max"
		else
			printTwoElementsSideBySide "$logo" "$info" "$print_cols_max"
		fi

	elif [ $info_cols -lt $term_cols ]; then
		if $print_logo_right ; then
			printTwoElementsSideBySide "$info" "" "$print_cols_max"
		else
			printTwoElementsSideBySide "" "$info" "$print_cols_max"
		fi
	fi


	## PRINT BOTTOM SPACER
	if $print_extra_new_line_bot; then echo ""; fi
}



##------------------------------------------------------------------------------
##
printLastLogins()
{
	## DO NOTHING FOR NOW -> This is disabled intentionally for now.
	## Printing logins should only be done under special circumstances:
	## 1. User configurable set to always on
	## 2. If the IP/terminal is very different from usual
	## 3. Other anomalies...
	if false; then
		printf "${fc_highlight}\nLAST LOGINS:\n${fc_info}"
		last -iwa | head -n 4 | grep -v "reboot"
	fi
}



##------------------------------------------------------------------------------
##
printSystemctl()
{
	systcl_num_failed=$(systemctl --failed |\
	                    grep "loaded units listed" |\
	                    head -c 1)

	if [ "$systcl_num_failed" -ne "0" ]; then
		local failed=$(systemctl --failed | awk '/UNIT/,/^$/')
		printf "${fc_crit}SYSTEMCTL FAILED SERVICES:\n"
		printf "${fc_info}${failed}${fc_none}\n\n"

	fi
}



##------------------------------------------------------------------------------
##
printHogsCPU()
{
	export LC_NUMERIC="C"

	## CHECK GLOBAL PARAMETERS
	if [ -z $crit_cpu_percent   ]; then exit 1; fi
	if [ -z $print_cpu_hogs_num ]; then exit 1; fi
	if [ -z $print_cpu_hogs     ]; then exit 1; fi


	## EXIT IF NOT ENABLED
	if ! $print_cpu_hogs; then return; fi


	## CHECK CPU LOAD
	local current=$(awk '{avg_1m=($1)} END {printf "%3.2f", avg_1m}' /proc/loadavg)
	local max=$(nproc --all)
	local percent=$(bc <<< "$current*100/$max")


	if [ $percent -gt $crit_cpu_percent ]; then
		## CALL TOP IN BATCH MODE
		## Check if "%Cpus(s)" is shown, otherwise, call "top -1"
		## Escape all '%' characters
		local top=$(nice 'top' -b -d 0.01 -n 1 )
		local cpus=$(echo "$top" | grep "Cpu(s)" )
		if [ -z "$cpus" ]; then
			local top=$(nice 'top' -b -d 0.01 -1 -n 1 )
			local cpus=$(echo "$top" | grep "Cpu(s)" )
		fi
		local top=$(echo "$top" | sed 's/\%/\%\%/g' )


		## EXTRACT ELEMENTS FROM TOP
		## - load:    summary of cpu time spent for user/system/nice...
		## - header:  the line just above the processes
		## - procs:   the N most demanding procs in terms of CPU time
		local load=$(echo "${cpus:9:36}" | tr '', ' ' )
		local header=$(echo "$top" | grep "%CPU" )
		local procs=$(echo "$top" |\
		              sed  '/top - /,/%CPU/d' |\
		              head -n "$print_cpu_hogs_num" )


		## PRINT WITH FORMAT
		printf "${fc_crit}SYSTEM LOAD:${fc_info}  ${load}\n"
		printf "${fc_crit}$header${fc_none}\n"
		printf "${fc_info}${procs}${fc_none}\n\n"
	fi
}



##------------------------------------------------------------------------------
##
printHogsMemory()
{
	## CHECK GLOBAL PARAMETERS
	if [ -z $crit_ram_percent  ]; then exit 1; fi
	if [ -z $crit_swap_percent ]; then exit 1; fi
	if [ -z $print_memory_hogs ]; then exit 1; fi


	## EXIT IF NOT ENABLED
	if ! $print_memory_hogs; then return; fi


	## CHECK RAM
	local ram_is_crit=false
	local mem_info=$('free' -m | head -n 2 | tail -n 1)
	local current=$(echo "$mem_info" | awk '{mem=($2-$7)} END {printf mem}')
	local max=$(echo "$mem_info" | awk '{mem=($2)} END {printf mem}')
	local percent=$(bc <<< "$current*100/$max")
	if [ $percent -gt $crit_ram_percent ]; then
		local ram_is_crit=true
	fi


	## CHECK SWAP
	## First check if there is any swap at all by checking /proc/swaps
	## If tehre is at least one swap partition listed, proceed
	local swap_is_crit=false
	local num_swap_devs=$(($(wc -l /proc/swaps | awk '{print $1;}') -1))	
	if [ "$num_swap_devs" -ge 1 ]; then
		local swap_info=$('free' -m | tail -n 1)
		local current=$(echo "$swap_info" | awk '{SWAP=($3)} END {printf SWAP}')
		local max=$(echo "$swap_info" | awk '{SWAP=($2)} END {printf SWAP}')
		local percent=$(bc <<< "$current*100/$max")
		if [ $percent -gt $crit_swap_percent ]; then
			local swap_is_crit=true
		fi
	fi

	## PRINT IF RAM OR SWAP ARE ABOVE THRESHOLD
	if $ram_is_crit || $swap_is_crit ; then
		local available=$(echo $mem_info | awk '{print $NF}')
		local procs=$(ps --cols=80 -eo pmem,size,pid,cmd --sort=-%mem |\
			      head -n 4 | tail -n 3 |\
			      awk '{$2=int($2/1024)"MB";}
		                   {printf("%5s%8s%8s\t%s\n", $1, $2, $3, $4)}')

		printf "${fc_crit}MEMORY:\t "
		printf "${fc_info}Only ${available} MB of RAM available!!\n"
		printf "${fc_crit}    %%\t SIZE\t  PID\tCOMMAND\n"
		printf "${fc_info}${procs}${fc_none}\n\n"
	fi
}






##==============================================================================
##	MAIN FUNCTION
##==============================================================================

## INCLUDE EXTERNAL DEPENDENCIES
## Only if the functions are not available
## If not, search in `common` folder
local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "$(type -t getFormatCode)" != 'function' ]; then
	source "$dir/../bash-tools/bash-tools/color.sh"
fi
if [ "$(type -t printWithOffset)" != 'function' ]; then
	source "$dir/../bash-tools/bash-tools/print_utils.sh"
fi



## DEFAULT CONFIGURATION
## WARNING! Do not edit directly, use configuration files instead

local logo="
        -oydNMMMMNdyo-
     -yNMMMMMMMMMMMMMMNy-
   .hMMMMMMmhsooshmMMMMMMh.
  :NMMMMmo.        .omMMMMN:
 -NMMMMs    -+ss+-    sMMMMN-
 hMMMMs   -mMMMMMMm-   sMMMMh
'MMMMM.  'NMMMMMMMMN'  .MMMMM
'MMMMM.  'NMMMMMMMMN'   yMMMM'
 hMMMMs   -mMMMMMMMMy.   -yMh
 -NMMMMs    -+ss+yMMMMy.   -.
  :NMMMMmo.       .yMMMMy.
   .hMMMMMMmhsoo-   .yMMMy
     -yNMMMMMMMMMy-   .o-
        -oydNMMMMNd/
"

local print_info="
	OS
	KERNEL
	CPU
	GPU
	SHELL
	DATE
	UPTIME
	LOCALIPV4
	EXTERNALIPV4
	SERVICES
	CPUTEMP
	SYSLOAD_MON%
	MEMORY_MON
	SWAP_MON
	HDDROOT_MON
	HDDHOME_MON"

local format_info="-c white"
local format_highlight="-c blue  -e bold"
local format_crit="-c 208   -e bold"
local format_deco="-c white -e bold"
local format_ok="-c blue  -e bold"
local format_error="-c 208   -e bold -e blink"
local format_logo="-c blue -e bold"

local crit_cpu_percent=40
local crit_ram_percent=75
local crit_swap_percent=25
local crit_hdd_percent=85
local crit_home_percent=85

local bar_length=13
local bar_num_digits=5
local info_label_width=16

local print_cols_max=100
local print_logo_right=false
local date_format="%Y.%m.%d - %T"
local print_cpu_hogs_num=3
local print_cpu_hogs=true
local print_memory_hogs=true
local clear_before_print=false
local print_extra_new_line_top=true
local print_extra_new_line_bot=true


## LOAD USER CONFIGURATION
local user_config_file="$HOME/.config/synth-shell/status.config"
local sys_config_file="/etc/andresgongora/synth-shell/status.config"
if   [ -f $user_config_file ]; then
	source $user_config_file
elif [ -f $sys_config_file ]; then
	source $sys_config_file
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
printHeader
printLastLogins
printSystemctl
printHogsCPU
printHogsMemory




## RUN SCRIPT
## This whole script is wrapped with "{}" to avoid environment pollution.
## It's also called in a subshell with "()" to REALLY avoid pollution.
}
(status)
unset status

### EOF ###
