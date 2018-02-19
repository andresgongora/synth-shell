




#!/bin/sh

## =============================================================================

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
	
## BACKGROUND COLORS
BGK='\033[40m'
BGR='\033[41m'
BGG='\033[42m'
BGY='\033[43m'
BGB='\033[44m'
BGM='\033[45m'
BGC='\033[46m'
BGW='\033[47m'

NC='\033[0m'		# NO COLOR

## =============================================================================

CLR_INFO=${W}	# INFO
CLR_HL=${BFB}	# HIGHLIGHT
CLR_CRIT=${BFC}	# CRITICAL
CLR_DCO=${BFK}	# DECORATION

## =============================================================================

LOGO_01="${CLR_HL}        -oydNMMMMNdyo-        ${NC}"
LOGO_02="${CLR_HL}     -yNMMMMMMMMMMMMMMNy-     ${NC}"
LOGO_03="${CLR_HL}   .hMMMMMMmhsooshmMMMMMMh.   ${NC}"
LOGO_04="${CLR_HL}  :NMMMMmo.        .omMMMMN:  ${NC}"
LOGO_05="${CLR_HL} -NMMMMs    -+ss+-    sMMMMN- ${NC}"
LOGO_06="${CLR_HL} hMMMMs   -mMMMMMMm-   sMMMMh ${NC}"
LOGO_07="${CLR_HL}'MMMMM.  'NMMMMMMMMN'  .MMMMM'${NC}"
LOGO_08="${CLR_HL}'MMMMM.  'NMMMMMMMMN'   yMMMM'${NC}"
LOGO_09="${CLR_HL} hMMMMs   -mMMMMMMMMy.   -yMh ${NC}"
LOGO_10="${CLR_HL} -NMMMMs    -+ss+yMMMMy.   -. ${NC}"
LOGO_11="${CLR_HL}  :NMMMMmo.       .yMMMMy.    ${NC}"
LOGO_12="${CLR_HL}   .hMMMMMMmhsoo-   .yMMMy    ${NC}"
LOGO_13="${CLR_HL}     -yNMMMMMMMMMy-   .o-     ${NC}"
LOGO_14="${CLR_HL}        -oydNMMMMNd/          ${NC}"

## =============================================================================


## KERNEL INFO
KERNEL=$(uname -r)
KERNEL=$(echo -e "${CLR_INFO}Kernel:\t\t ${CLR_HL}$KERNEL${NC}")


## SHELL
SHELL=$(readlink /proc/$$/exe)
SHELL=$(echo -e "${CLR_INFO}Shell:\t\t ${CLR_HL}$SHELL${NC}")


## CPU INFO
CPU=$(cat /proc/cpuinfo | grep "model name" | uniq)
CPU="${CPU#*:}"
CPU=$(echo "$CPU" | sed 's/  */ /g') # Trim spaces
CPU=$(echo -e "${CLR_INFO}CPU:\t\t${CLR_HL}$CPU${NC}")


## OS DISTRO NAME
OS=$(cat /etc/*-release | grep PRETTY_NAME)
OS="${OS#*=}"
OS=$(echo "$OS" | sed 's/"//g') # remove " characters
OS=$(echo -e "${CLR_INFO}OS:\t\t ${CLR_HL}$OS${NC}")


## SYS DATE
SYSDATE=$(date)
SYSDATE=$(echo -e "${CLR_INFO}Date:\t\t ${CLR_HL}$SYSDATE${NC}")


## LOGIN
LOGIN=$(echo -e "${CLR_INFO}Login:\t\t ${CLR_HL}$USER@$HOSTNAME${NC}")


## LOCAL IP
LOCALIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
LOCALIP=$(echo -e "${CLR_INFO}Local IP:\t ${CLR_HL}$LOCALIP${NC}")


## EXTERNAL IP
EXTERNALIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
EXTERNALIP=$(echo -e "${CLR_INFO}External IP:\t ${CLR_HL}$EXTERNALIP${NC}")





## =============================================================================



WIDTH=$(tput cols)



printHeader()
{
	printf "\n\r $LOGO_01		\n\r"
	printf " $LOGO_02		\n\r"
	printf " $LOGO_03		\n\r"
	printf " $LOGO_04 \t$OS		\n\r"
	printf " $LOGO_05 \t$KERNEL	\n\r"
	printf " $LOGO_06 \t$CPU	\n\r"
	printf " $LOGO_07 \t$SHELL	\n\r"
	printf " $LOGO_09 \t$SYSDATE	\n\r"
	printf " $LOGO_09 \t$LOGIN	\n\r"
	printf " $LOGO_10 \t$LOCALIP	\n\r"
	printf " $LOGO_11 \t$EXTERNALIP	\n\r"
	printf " $LOGO_12		\n\r"
	printf " $LOGO_13		\n\r"
	printf " $LOGO_14	    \n\r\n\r"
}


#for ((x = 0; x < ${WIDTH}; x++)); do
#  	printf %s -
#done
	
#printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	
#printf 'HOLA %20s ADIOS\n' | tr ' ' -
#printf 'HOLA %20s ADIOS\n'
	
	
#printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
#sensors | grep Core



#set -x #echo on



#dmesg -TP --level=err,crit,alert,emerg

#free -mhwt

clear
printHeader

printf "\nLast logins:\n"
last -iwa | head | grep -v "reboot"


#https://wiki.archlinux.org/index.php/System_maintenance


printf "\nModules that failed to load:\n"
systemctl --failed
#sudo journalctl -p 3 -xb # Find errors in the logs
#sudo find -xtype l -print # Find broken symlinks



netstat -atp #add -n to show IPs instead of host names







