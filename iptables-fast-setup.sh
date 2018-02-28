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


##############################################################################
## INITIALIZE
##

## FLUSH ALL RULES
for table in $(</proc/net/ip_tables_names)
do 
	iptables -t $table -F
	iptables -t $table -X
	iptables -t $table -Z 
done


## CREATE NEW CHAINS
iptables -N TCP
iptables -N UDP
iptables -N VPN



##############################################################################
## INPUT
##
iptables -A INPUT           -m conntrack --ctstate RELATED,ESTABLISHED  -j ACCEPT	$com "Already established or related connections"
iptables -A INPUT -i lo                                                 -j ACCEPT	$com "Loopback"
iptables -A INPUT           -m conntrack --ctstate INVALID              -j DROP 	$com "Drop invalid packets"
iptables -A INPUT -p icmp   --icmp-type 8 -m conntrack --ctstate NEW    -j ACCEPT 	$com "Allow incomming pings"
iptables -A INPUT -p udp    -m conntrack --ctstate NEW                  -j UDP 		$com "If UPD, handle by UPD chain"
iptables -A INPUT -p tcp    --syn -m conntrack --ctstate NEW            -j TCP 		$com "If TCP, handle by TCP chain"
#iptables -A INPUT -i tun+   -m conntrack --ctstate NEW                 -j VPN		 $com "If VPN, handle by VPN chain"
#iptables -A INPUT -j REJECT --reject-with icmp-proto-unreach 			             $com "Rechazar en lugar de drop"


##############################################################################
## OUTPUT
##
#todo


##############################################################################
## FORWARD
##
#iptables -A FORWARD -i enp0s25 -o lxcbr0 -p tcp --syn --dport 8000 -m conntrack --ctstate NEW -j ACCEPT
#iptables -A FORWARD -i enp0s25 -o lxcbr0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -i lxcbr0 -o enp0s25 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#iptables -t nat -A PREROUTING -i enp0s25 -p tcp --dport 8000 -j DNAT --to-destination 10.0.3.202
#iptables -t nat -A POSTROUTING -o lxcbr0 -p tcp --dport 8000 -d 10.0.3.202 -j SNAT --to-source 150.214.109.169

iptables -A FORWARD -p tcp --dport 8000 -m conntrack --ctstate NEW -j ACCEPT $com	"A"
iptables -A FORWARD -p udp --dport 8000 -m conntrack --ctstate NEW -j ACCEPT $com	"B"

iptables -A FORWARD -o lxcbr0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT $com	"C"
iptables -A FORWARD -i lxcbr0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT $com	"D"

iptables -t nat -A PREROUTING -p tcp --dport 8000 -j DNAT --to-destination 10.0.3.202:8000 $com	"E"
iptables -t nat -A PREROUTING -p udp --dport 8000 -j DNAT --to-destination 10.0.3.202:8000 $com	"F"



##############################################################################
## TCP
##
iptables -A TCP -p tcp --dport 22           -j ACCEPT	$com "SSH" #Comentado para utilizar portknocking
iptables -A TCP -p tcp --dport 80		    -j ACCEPT	$com "PORT 80 for web server"
iptables -A TCP -p tcp --dport 443		    -j ACCEPT	$com "PORT 443 for SSL (https) web server"
iptables -A TCP -p tcp --dport 10011		-j ACCEPT	$com "Team Speak 3 Server: Query Port"
iptables -A TCP -p tcp --dport 30033 		-j ACCEPT	$com "Team Speak 3 Server: File Transfer"
iptables -A TCP -p tcp --dport 40000:40010 	-j ACCEPT	$com "Deluge"
iptables -A TCP -p tcp --dport 8112 		-j ACCEPT	$com "Deluge-web"
iptables -A TCP -p tcp --dport 58846		-j ACCEPT	$com "Deluge-daemon"
iptables -A TCP -p tcp --dport 3306		    -j ACCEPT	$com "MariaDB"
iptables -A TCP -p tcp --dport 53		    -j ACCEPT	$com "unbound DNS server"
#iptables -A TCP -p tcp --dport 21		    -j ACCEPT	$com "FTP Commands"
#iptables -A TCP -p tcp --dport 40011:40019	-j ACCEPT	$com "FTP Data"
iptables -A TCP -p tcp --dport 8096		    -j ACCEPT	$com "emby htpp"
iptables -A TCP -p tcp --dport 8020		    -j ACCEPT	$com "emby https"


#Otros paquetes TCP:
iptables -A TCP -p tcp	--dport 2869 		-j ACCEPT						$com    "UPnP"
iptables -A TCP -p tcp ! --syn 				-j REJECT --reject-with tcp-rst	$com	"Reject any other TCP connection instead of just dropping them"



##############################################################################
## UDP
##
iptables -A UDP -p udp --dport 9987         -j ACCEPT	$com "Team Speak 3 Server"
iptables -A UDP -p udp --dport 40000:40010  -j ACCEPT	$com "Deluge"    
iptables -A UDP -p udp --dport 58846        -j ACCEPT	$com "Deluge-daemon"
iptables -A UDP -p udp --dport 123          -j ACCEPT	$com "Network Time Protocol"
iptables -A UDP -p udp --dport 53           -j ACCEPT	$com "Unbound DNS server"
#iptables -A UDP -p udp --dport 1194		-j ACCEPT	$com "openVPN@server (configurado para UDP)"


#Otros paquetes UDP
#iptables -A UDP -p udp --dport 1900		-j ACCEPT	$com    "UPnP"



##############################################################################
## VPN
##
#iptables -A FORWARD -i tun+ -o eht0					-j ACCEPT		$com	"VPN in-out. Unir VPN y LAN"
#iptables -A FORWARD -i eth0 -o tun+					-j ACCEPT		$com    "VPN in-out. Unir VPN y LAN"
#iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0	-j MASQUERADE	$com    "VPN"

#Accesibles solo desde VPN:
#iptables -A VPN -i tun+ -p tcp --dport 8112			-j ACCEPT		$com    "Deluge WEB"



#--- Configurar chains -----------------------------------------------------------------
iptables -P FORWARD	DROP
iptables -P OUTPUT	ACCEPT
iptables -P INPUT	DROP



##############################################################################
## ECHO
##
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


echo ""
echo ""
echo ""
echo ""
echo "To make these settings permanent (hold after reboot), run as root:"
echo "	iptables-save > /etc/iptables/iptables.rules"




### EOF ###

