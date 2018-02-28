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
##	1. Flush all rules
##	2. Create new chains: TCP, UDP and VPN
##	3. General rules, redirect TCP, UDP and VPN to their specific chains
##		3.1 Incomming
##		3.2 Forward
##		3.3 Outgoing
##	4. Specific rules for TCP, UDP and VPN
##		
##
##	To make these settings permanent (hold after reboot), run as root:
##	iptables-save > /etc/iptables/iptables.rules
##
##
##	MAN:
##
##	-t {filter,nat,···}
##	Specify the table IPTABLES should operate on. If non given, -t filter
##	is assumed. Filter contains the builtin INPUT, FORWARD and OUTPUT.
##	NAT is meant for packets that create new connections, and contains
##	PREROUTING, INTPUT, OUTPUT and POSTROUTING
##
##	-p, --protocol {tcp, udp, udplite, icmp, icmpv6,esp, ah, sctp, mh, all}
##	A "!" before the protocol inverts the test. If omitted, the rule will
##	apply as if "all" was specified
##
##	-s, --source address[/mask][,...]  and  -d, --destination
##	Address  can be either a network name, a hostname, a network IP address (with /mask),
##	or a plain IP address. 
##
##	-m, --match match
##	Specifies a match to use, that is, an extension module that tests for a specific property. 
##	The set of matches make up the condition under which a target is invoked.
##	Matches are evaluated first to last as specified on the command line and work in
##	short-circuit fashion, i.e. if one extension yields false, evaluation will stop.
##
##	-j, --jump target
##	This specifies the target of the rule; i.e., what to do if the packet matches it.
##	The target can be a  user-defined chain  (other  than  the one this rule is in),
##	one of the special builtin targets which decide the fate of the packet immediately.
##
##	-i, --in-interface name
##	Name of an interface via which a packet was received (only for packets entering
##	the INPUT, FORWARD and PREROUTING  chains). When  the "!" argument is used before
##	the interface name, the sense is inverted.  If the interface name ends in a "+",
##	then any interface which begins with this name will match.
##	If this option is omitted, any interface name will match.
##
##	-o, --out-interface name
##	See --in-interface, but for FORWARD, OUTPUT and POSTROUTING.
##
##






com='-m comment --comment'


################################################################################
##  FUNCTIONS                                                                 ##
################################################################################

flushIptables() {

	## FLUSH ALL TABLES
	for table in $(</proc/net/ip_tables_names)
	do 
		iptables -t $table -F
		iptables -t $table -X
		iptables -t $table -Z 
	done

	## ACCEPT ALL
	iptables -P FORWARD	ACCEPT
	iptables -P OUTPUT	ACCEPT
	iptables -P INPUT	ACCEPT

}


applyDefaultPolicy() {

	iptables -P FORWARD	DROP
	iptables -P OUTPUT	ACCEPT
	iptables -P INPUT	DROP
}



printRules() {

	echo ""
	echo "##############################################################################"
	echo "## FILTER RULES"
	echo "##############################################################################"
	echo ""
	sudo iptables -nvL -t filter


	echo ""
	echo "##############################################################################"
	echo "## NAT RULES"
	echo "##############################################################################"
	echo ""
	sudo iptables -nvL -t nat

}

allowLXC() {

	## TAKEN FROM '/usr/lib/lxc/lxc-net'

	iptables -A INPUT	-i lxcbr0 -p tcp --dport 53		-j ACCEPT
	iptables -A INPUT	-i lxcbr0 -p udp --dport 53		-j ACCEPT
	iptables -A INPUT	-i lxcbr0 -p tcp --dport 67		-j ACCEPT
	iptables -A INPUT	-i lxcbr0 -p udp --dport 67		-j ACCEPT

	iptables -A FORWARD	-o lxcbr0				-j ACCEPT
	iptables -A FORWARD	-i lxcbr0				-j ACCEPT

	iptables -t nat	   -A POSTROUTING -s 10.0.3.0/24 ! -d 10.0.3.0/24    -j MASQUERADE
	iptables -t mangle -A POSTROUTING -o lxcbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill

}







################################################################################
##  MAIN                                                                      ##
################################################################################

## CHECK PRIVILEGES
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi


## FLUSH ALL RULES
flushIptables










##############################################################################
## INPUT
##
iptables -A INPUT           -m conntrack --ctstate RELATED,ESTABLISHED  -j ACCEPT	$com "Already established or related connections"
iptables -A INPUT -i lo                                                 -j ACCEPT	$com "Loopback"
iptables -A INPUT           -m conntrack --ctstate INVALID              -j DROP 	$com "Drop invalid packets"
iptables -A INPUT -p icmp   --icmp-type 8 -m conntrack --ctstate NEW    -j ACCEPT 	$com "Allow incomming pings"
#iptables -A INPUT -p udp    -m conntrack --ctstate NEW                  -j UDP 		$com "If UPD, handle by UPD chain"
#iptables -A INPUT -p tcp    --syn -m conntrack --ctstate NEW            -j TCP 		$com "If TCP, handle by TCP chain"
#iptables -A INPUT -i tun+   -m conntrack --ctstate NEW                 -j VPN		 $com "If VPN, handle by VPN chain"
#iptables -A INPUT -j REJECT --reject-with icmp-proto-unreach 			             $com "Rechazar en lugar de drop"


##############################################################################


## EXAMPLE FOR LCX
## Host: External: 150.214.109.169, lxcbr0: 10.0.3.1
## Container: lxcbr0: 10.0.3.202
## Map port 222 on Container as 22 on the host
## ie. the container runs SSH on port 222, when we SSH to 150.214.109.169 we actually
## want to log into the conainer.

## REDIRECT EXTERNAL INCOMMING PACKETS TO CONTAINER
#iptables -t nat -A PREROUTING ! -d 127.0.0.0/8 -p tcp -m addrtype --dst-type LOCAL --dport 22 -j DNAT --to-destination 10.0.3.202:222

## REDIRECT LOCAL PACKETS FROM HOST TO CONTAINER
## Necessary to make the port mapping visible from within the host
#iptables -t nat -A OUTPUT ! -d 127.0.0.0/8 -p tcp -m addrtype --dst-type LOCAL --src-type LOCAL --dport 22  -j DNAT --to-destination 10.0.3.202:222

## FORWARD FOR OTHER CONTAINERS
#iptables -t nat -A POSTROUTING -s 10.0.3.0/24 -d 10.0.3.202 -p tcp -m tcp -m multiport --dports 222 -j MASQUERADE

## FORWARD PACKAGES FROM CONTAINER
## Usually not needed, as lxcbr0 forwards everything by default. See '/usr/lib/lxc/lxc-net'
#iptables -A FORWARD 	-p tcp -d 10.0.3.202 --dport 222		-j ACCEPT
#iptables -A FORWARD	-m conntrack --ctstate ESTABLISHED,RELATED	-j ACCEPT








iptables -A INPUT -p tcp --dport 22           -j ACCEPT	$com "SSH" #Comentado para utilizar portknocking


## REDIRECT EXTERNAL INCOMMING PACKETS TO CONTAINER
iptables -t nat -A PREROUTING ! -d 127.0.0.0/8 -p tcp -m addrtype --dst-type LOCAL --dport 222 -j DNAT --to-destination 10.0.3.202:222

## REDIRECT LOCAL PACKETS FROM HOST TO CONTAINER
## Necessary to make the port mapping visible from within the host
iptables -t nat -A OUTPUT ! -d 127.0.0.0/8 -p tcp -m addrtype --dst-type LOCAL --src-type LOCAL --dport 222  -j DNAT --to-destination 10.0.3.202:222

## FORWARD FOR OTHER CONTAINERS
iptables -t nat -A POSTROUTING -s 10.0.3.0/24 -d 10.0.3.202 -p tcp -m tcp -m multiport --dports 222 -j MASQUERADE

## FORWARD PACKAGES FROM CONTAINER
## Usually not needed, as lxcbr0 forwards everything by default. See '/usr/lib/lxc/lxc-net'
iptables -A FORWARD 	-p tcp -d 10.0.3.202 --dport 222		-j ACCEPT
iptables -A FORWARD	-m conntrack --ctstate ESTABLISHED,RELATED	-j ACCEPT


#--- Configurar chains -----------------------------------------------------------------


allowLXC
applyDefaultPolicy
printRules



### EOF ###

