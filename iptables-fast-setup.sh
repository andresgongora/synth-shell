#!/bin/sh

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	|                         IPTABLES - FAST SETUP                         |
##	|                                                                       |
##	| Copyright (c) 2018, Andres Gongora <mail@andresgongora.com>.          |
##	|                                                                       |
##	| This program is free software: you can redistribute it and/or modify  |
##	| it under the terms of the GNU General Public License as published by  |
##	| the Free Software Foundation, either version 3 of the License, or     |
##	| (at your option) any later version.                                   |
##	|                                                                       |
##	| This program is distributed in the hope that it will be useful,       |
##	| but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##	| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##	| GNU General Public License for more details.                          |
##	|                                                                       |
##	| You should have received a copy of the GNU General Public License     |
##	| along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##	|                                                                       |
##	+-----------------------------------------------------------------------+


##
##	This is a helper script to set IPTABLES up
##
##
##	1. Flush all rules, accept all IPv4 (for now) and drop all IPv6
##	2. Create new chains: TCP, UDP and VPN
##	3. General rules, redirect TCP, UDP and VPN to their specific chains
##		3.1 Incomming
##		3.2 Forward
##		3.3 Outgoing
##	4. Specific rules for TCP, UDP and VPN
##	5. Apply default policies:
##		5.1 IPv4: Accept output, filter input/forward
##		5.2 Ipv6: Drop all
##		
##
##	To make these settings permanent (hold after reboot), run as root:
##	iptables-save > /etc/iptables/iptables.rules
##
##
##
##	SIMPLE FILTER
##	=============
##
##	-t {filter,nat,···}
##		Specify the table IPTABLES should operate on. If non given, -t filter
##		is assumed. Filter contains the builtin INPUT, FORWARD and OUTPUT.
##		NAT is meant for packets that create new connections, and contains
##		PREROUTING, INTPUT, OUTPUT and POSTROUTING
##
##	-p, --protocol {tcp, udp, udplite, icmp, icmpv6,esp, ah, sctp, mh, all}
##		A "!" before the protocol inverts the test. If omitted, the rule will
##		apply as if "all" was specified
##
##	-s, --source address[/mask][,...]  and  -d, --destination
##		Address  can be either a network name, a hostname, a network IP address
##		(with /mask), or a plain IP address. 
##
##	-m, --match match
##		Specifies a match to use, that is, an extension module that tests 
##		for a specific property. The set of matches make up the condition
##		 under which a target is invoked. Matches are evaluated first
##		to last as specified on the command line and work in short-circuit
##		fashion, i.e. if one extension yields false, evaluation will stop.
##
##	-j, --jump target
##		This specifies the target of the rule; i.e., what to do if the
##		packet matches it. The target can be a  user-defined chain
##		(other  than  the one this rule is in), one of the special builtin
##		targets which decide the fate of the packet immediately.
##
##	-i, --in-interface name
##		Name of an interface via which a packet was received (only for
##		packets entering the INPUT, FORWARD and PREROUTING  chains).
##		When  the "!" argument is used beforethe interface name, 
##		the sense is inverted.  If the interface name ends in a "+",
##		then any interface which begins with this name will match.
##		If this option is omitted, any interface name will match.
##
##	-o, --out-interface name
##		See --in-interface, but for FORWARD, OUTPUT and POSTROUTING.
##
##
##
##	RATE LIMITING
##	=============
##
##	-m recent
##		Allows you to dynamically create a list of IP addresses and
##		then match against that list in a few different ways. 
##
##		--name
##		    Specify the list to use for the commands. If no name is given
##			then 'DEFAULT' will be used. 
##
##		--set
##			This will add the source address of the packet to the list. 
##			If the source address is already in the list, this will update 
##			the existing entry. This will always return success
##			(or failure if '!' is passed in).
##
##		--rcheck
##			Check to see if the IP has been registered and compare against,
##			but do not update it's timestamp. This is useful to establish
##			a pure rate limit check, as opposed to update.
##
##		--update
##			Similar to --rcheck, but update the timestamp of the entry.
##			This is useful to enforce a penalty timeout that has to pass
##			before accepting new connections. If the request continue to arrive
##			at a higher than allowed rate, all of them will be blocked until
##			the timmeout has finished without a single request arriving.
##
##		--seconds
##			In conjunction with rcheck or update, applies the rule only if the
##			elapsed time from the request under inspection to the last stored
##			entry in the list is shorter.
##
##		--rttl
##			Verify that the TTL value of the current packet is the same
##			as the original packet that was used to set the original entry
##			in the recent list. This can be used to verify that people are 
##			not spoofing their source address to deny others access to your
##			servers by making use of the recent match.





com='-m comment --comment'

## IF ANYTHING FAILS: EXIT
set -e


## CHECK PRIVILEGES
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi



################################################################################
##	FUNCTIONS
################################################################################


##------------------------------------------------------------------------------
##	IPTABLES HELPER FUNCTIONS
##------------------------------------------------------------------------------

flushIptables() {

	## ACCEPT ALL IPv4
	iptables -P FORWARD	ACCEPT
	iptables -P OUTPUT	ACCEPT
	iptables -P INPUT	ACCEPT


	## FLUSH ALL TABLES
	for table in $(</proc/net/ip_tables_names)
	do 
		iptables -t $table -F
		iptables -t $table -X
		iptables -t $table -Z 
	done


	## FLUSH IPv6 TABLES
	ip6tables -F
	ip6tables -X
	ip6tables -Z
}


applyDefaultPolicy() {

	## IPv4
	iptables -P FORWARD	DROP
	iptables -P OUTPUT	ACCEPT
	iptables -P INPUT	DROP

	## IPv6
	ip6tables -P FORWARD	DROP
	ip6tables -P OUTPUT	DROP
	ip6tables -P INPUT	DROP
}


printRules() {

	echo ""
	echo "+----------------------------------------------------------------------------+"
	echo "|                            IPv4 FILTER RULES                               |"
	echo "+----------------------------------------------------------------------------+"
	echo ""
	sudo iptables -nL -t filter


	echo ""
	echo ""
	echo "+----------------------------------------------------------------------------+"
	echo "|                            IPv4 NAT RULES                                  |"
	echo "+----------------------------------------------------------------------------+"
	echo ""
	sudo iptables -nL -t nat


	echo ""
	echo ""
	echo "+----------------------------------------------------------------------------+"
	echo "|                               IPv6 RULES                                   |"
	echo "+----------------------------------------------------------------------------+"
	echo ""
	sudo ip6tables -nL


	echo ""
	echo ""
	echo "+----------------------------------------------------------------------------+"
	echo "|    NOTICE:                                                                 |"
	echo "|    To make these settings permanent (hold after reboot), run as root:      |"
	echo "|    iptables-save > /etc/iptables/iptables.rules                            |"
	echo "+----------------------------------------------------------------------------+"
	echo ""

}


##------------------------------------------------------------------------------
##	LXC HELPER FUNCTIONS
##------------------------------------------------------------------------------

LXC_INTERFACE=lxcbr0
LXC_NETWORK=10.0.3.0/24


reapplyLXCdefaultRules() {

	## TAKEN FROM '/usr/lib/lxc/lxc-net'
	## Automatically run when LXC-net starts
	## Included here in case you want to re-apply them after
	## reseting iptables, thus eliminating the need to restart lxc-net

	iptables -A INPUT	-i $LXC_INTERFACE -p tcp --dport 53     -j ACCEPT
	iptables -A INPUT	-i $LXC_INTERFACE -p udp --dport 53     -j ACCEPT
	iptables -A INPUT	-i $LXC_INTERFACE -p tcp --dport 67     -j ACCEPT
	iptables -A INPUT	-i $LXC_INTERFACE -p udp --dport 67     -j ACCEPT

	iptables -A FORWARD	-o $LXC_INTERFACE                       -j ACCEPT
	iptables -A FORWARD	-i $LXC_INTERFACE                       -j ACCEPT

	iptables -t nat	   -A POSTROUTING -s $LXC_NETWORK ! -d $LXC_NETWORK          -j MASQUERADE
	iptables -t mangle -A POSTROUTING -o $LXC_INTERFACE -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill

}


forwardLXCport() {

	PROTOCOL=$1
	HOST_PORTS=$2
	LXC_IP=$3
	LXC_PORTS=$4
	LXC_PORTS_DNAT=(${LXC_PORTS//:/-})


	## REDIRECT EXTERNAL INCOMMING PACKETS TO CONTAINER
	iptables -t nat -A PREROUTING   ! -d 127.0.0.0/8                       \
	                                -p "$PROTOCOL"	                       \
	                                -m addrtype --dst-type LOCAL           \
	                                -m multiport --dports "$HOST_PORTS"    \
	                                -j DNAT --to-destination "$LXC_IP:$LXC_PORTS_DNAT"


	## REDIRECT LOCAL PACKETS FROM HOST TO CONTAINER
	## Necessary to make the port mapping visible from within the host
	iptables -t nat -A OUTPUT       ! -d 127.0.0.0/8                       \
	                                -p "$PROTOCOL"                         \
	                                -m addrtype --dst-type LOCAL --src-type LOCAL\
	                                -m multiport --dports "$HOST_PORTS"    \
	                                -j DNAT --to-destination "$LXC_IP:$LXC_PORTS_DNAT"


	## REDIRECT PACKETS FROM OTHER CONAINERS TO TARGET CONTAINER
	iptables -t nat -A POSTROUTING  -s "$LXC_NETWORK" -d "$LXC_IP"         \
	                                -p "$PROTOCOL"                         \
	                                -m multiport --dports "$LXC_PORTS"     \
	                                -j MASQUERADE


	## ALLOW FORWARDING FOR THIS SPECIFIC PORT
	## 	This is usually not needed, as LXC's default rules
	##	already allow forwarding for the whole $LXC_INTERFACE.
	##	However, these are very specific and narrow rules that should
	##	continue working even if forwarding for LXC has been disabled 
	##	(still, Linux's systemctl must have forwarding enabled!!)

	## Incoming Related
	iptables -A FORWARD     -o $LXC_INTERFACE -d "$LXC_IP" -p $PROTOCOL    \
	                        -m conntrack --ctstate ESTABLISHED,RELATED     \
	                        -j ACCEPT
	## Outgoing Related
	iptables -A FORWARD     -i $LXC_INTERFACE -s "$LXC_IP" -p $PROTOCOL    \
	                        -m conntrack --ctstate ESTABLISHED,RELATED     \
	                        -j ACCEPT
	## Incoming New
	iptables -A FORWARD     -o $LXC_INTERFACE -d "$LXC_IP" -p $PROTOCOL    \
	                        -m conntrack --ctstate NEW                     \
	                        -m multiport --dports "$LXC_PORTS"             \
	                        -j ACCEPT
	## Outgoing New
	iptables -A FORWARD     -i $LXC_INTERFACE -s "$LXC_IP" -p $PROTOCOL    \
	                        -m conntrack --ctstate NEW -m multiport        \
	                        --dports "$HOST_PORTS"                         \
	                        -j ACCEPT

}


################################################################################
##	RULES
################################################################################

## FLUSH ALL RULES
flushIptables


## CREATE NEW CHAINS
iptables -N UDP
iptables -N TCP
iptables -N SSH
iptables -N VPN



##------------------------------------------------------------------------------
##	INPUT
##------------------------------------------------------------------------------

iptables -A INPUT	-m conntrack --ctstate RELATED,ESTABLISHED          -j ACCEPT
iptables -A INPUT	-i lo                                               -j ACCEPT
#iptables -A INPUT 	-p 41                                               -j ACCEPT   $com "ICMPv6 Neighbor Discovery"
iptables -A INPUT	-m conntrack --ctstate INVALID                      -j DROP
#iptables -A INPUT	-m recent --name BLACKLIST                          -j BLACKLIST
iptables -A INPUT	-p icmp --icmp-type 8 -m conntrack --ctstate NEW    -j ACCEPT	$com "Allow incomming pings"
iptables -A INPUT	-p udp -m conntrack --ctstate NEW                   -j UDP
iptables -A INPUT	-p tcp --syn -m conntrack --ctstate NEW             -j TCP
#iptables -A INPUT	-i tun+ -m conntrack --ctstate NEW                  -j VPN


## FOR ALL OTHER PROTOCOLS, REJECT
## This imitates Linux standard behaviour
iptables -A INPUT 	-j REJECT --reject-with icmp-proto-unreachable



##------------------------------------------------------------------------------
##	FORWARD
##------------------------------------------------------------------------------



##------------------------------------------------------------------------------
##	OUTPUT
##------------------------------------------------------------------------------



##------------------------------------------------------------------------------
##	BLACKLIST CHAIN
##------------------------------------------------------------------------------
#iptables -A BLACKLIST 	-m recent --name BLACKLIST --rttl --rcheck         \
#                      	--seconds   10 --hitcount  4                       \
#                     	-j DROP	$com "Rate limit 3 in 10s"


##------------------------------------------------------------------------------
##	TCP CHAIN
##------------------------------------------------------------------------------

#iptables -A TCP 	-p tcp --dport 21               -j ACCEPT	$com "FTP Commands"
iptables -A TCP 	-p tcp --dport 22               -j SSH		$com "SSH: send to SSH chain"
#iptables -A TCP 	-p tcp --dport 53               -j ACCEPT	$com "unbound DNS server"
#iptables -A TCP 	-p tcp --dport 80               -j ACCEPT	$com "PORT 80 for web server"
#iptables -A TCP 	-p tcp --dport 443              -j ACCEPT	$com "PORT 443 for SSL (https) web server"

#iptables -A TCP 	-p tcp --dport 2869             -j ACCEPT	$com "UPnP"
#iptables -A TCP 	-p tcp --dport 3306             -j ACCEPT	$com "MariaDB"
#iptables -A TCP 	-p tcp --dport 8096             -j ACCEPT	$com "emby htpp"
#iptables -A TCP 	-p tcp --dport 8020             -j ACCEPT	$com "emby https"
#iptables -A TCP 	-p tcp --dport 8112             -j ACCEPT	$com "Deluge-web"
iptables -A TCP 	-p tcp --dport 24800             -j ACCEPT	$com "Synergy Server"
#iptables -A TCP 	-p tcp --dport 10011		-j ACCEPT	$com "Team Speak 3 Server: Query Port"
#iptables -A TCP 	-p tcp --dport 30033 		-j ACCEPT	$com "Team Speak 3 Server: File Transfer"
#iptables -A TCP 	-p tcp --dport 40011:40019	-j ACCEPT	$com "FTP Data"
#iptables -A TCP 	-p tcp --dport 40000:40010      -j ACCEPT	$com "Deluge"
#iptables -A TCP 	-p tcp --dport 58846		-j ACCEPT	$com "Deluge-daemon"




## TCP PORTSCAN PROTECTION
##
## >>> WARNING! <<<
## If this section is enabled, no TCP coonnection will get past here!
##
## Packets are either rejected or droped. Dropping makes the scan
## even slower and may confuse the attacker. But rejecting is
## Linux's Linux standard behaviour.
##
## This drops packets that arrive at closed ports at rate faster
## than 2 (>=3) every 10 seconds, and rejects the remainder. 
##
iptables -I TCP 	-p tcp -m recent --name TCP-PORTSCAN --rcheck --rsource --seconds 10 --hitcount 3 --rttl -j DROP
iptables -A TCP 	-p tcp -m recent --name TCP-PORTSCAN --set --rsource -j REJECT --reject-with tcp-reset


## REJECT ALL OTHER TCP PACKETS
## This imitates Linux standard behaviour and helps against port scans
iptables -A TCP 	-p tcp                          -j REJECT --reject-with tcp-reset



##------------------------------------------------------------------------------
##	UDP CHAIN
##------------------------------------------------------------------------------

#iptables -A UDP 	-p udp --dport 9987             -j ACCEPT	$com "Team Speak 3 Server"
#iptables -A UDP 	-p udp --dport 40000:40010      -j ACCEPT	$com "Deluge"    
#iptables -A UDP 	-p udp --dport 58846            -j ACCEPT	$com "Deluge-daemon"
#iptables -A UDP 	-p udp --dport 123              -j ACCEPT	$com "Network Time Protocol"
#iptables -A UDP 	-p udp --dport 53               -j ACCEPT	$com "Unbound DNS server"
#iptables -A UDP 	-p udp --dport 1194             -j ACCEPT	$com "openVPN@server (configurado para UDP)"
#iptables -A UDP 	-p udp --dport 1900             -j ACCEPT	$com "UPnP"


## UDP PORTSCAN PROTECTION
##
## >>> WARNING! <<<
## If this section is enabled, no UDP coonnection will get past here!
##
## Packets are either rejected or droped. Dropping makes the scan
## even slower and may confuse the attacker. But rejecting is
## Linux's Linux standard behaviour.
##
## This drops packets that arrive at closed ports at rate faster
## than 2 (>=3) every 10 seconds, and rejects the remainder. 
##
iptables -I UDP 	-p udp -m recent --name UDP-PORTSCAN --rcheck --rsource --seconds 10 --hitcount 3 --rttl -j DROP
iptables -A UDP 	-p udp -m recent --name UDP-PORTSCAN --set --rsource -j REJECT --reject-with icmp-port-unreachable


## REJECT ALL OTHER UDP PACKETS
## This imitates Linux standard behaviour and helps against port scans
iptables -A UDP -p udp                          -j REJECT --reject-with icmp-port-unreachable



##------------------------------------------------------------------------------
##	SSH CHAIN WITH LOGGING-ATTEMPT RATE-LIMITING
##------------------------------------------------------------------------------
iptables -A SSH -m recent --name SSH-RL --rttl --rcheck --seconds   10 --hitcount  4 -j DROP    $com "Rate limit 3 in 10s"
iptables -A SSH -m recent --name SSH-RL --rttl --rcheck --seconds 1800 --hitcount 31 -j DROP    $com "Protect against slow attacks"
iptables -A SSH -m recent --name SSH-RL --set --rsource -j ACCEPT  $com "Remmember attempt, but otherwise accept it"    




##------------------------------------------------------------------------------
##	VPN
##------------------------------------------------------------------------------

#iptables -A FORWARD -i tun+ -o eht0					-j ACCEPT		$com	"VPN in-out. Unir VPN y LAN"
#iptables -A FORWARD -i eth0 -o tun+					-j ACCEPT		$com    "VPN in-out. Unir VPN y LAN"
#iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0	-j MASQUERADE	$com    "VPN"

#Accesibles solo desde VPN:
#iptables -A VPN -i tun+ -p tcp --dport 8112			-j ACCEPT		$com    "Deluge WEB"





################################################################################
##	LXC
################################################################################

reapplyLXCdefaultRules

## 2018 TELEOLFACTION GIRAFF EXPERIMENT
forwardLXCport  tcp     8000            10.0.3.202      8000            # MQTT
forwardLXCport  tcp     8002            10.0.3.202      8002            # MQTT
forwardLXCport  udp     8000            10.0.3.202      8000            # MQTT
forwardLXCport  udp     8002            10.0.3.202      8002            # MQTT
forwardLXCport  tcp     8080            10.0.3.202      8080            # NODEJS
forwardLXCport  udp     8080            10.0.3.202      8080            # NODEJS



################################################################################
##	DEFAULT POLICY
################################################################################


applyDefaultPolicy
printRules


### EOF ###

