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


##############################################################################
## FLUSH ALL RULES
##

iptables -P FORWARD	ACCEPT
iptables -P OUTPUT	ACCEPT
iptables -P INPUT	ACCEPT


for table in $(</proc/net/ip_tables_names)
do 
	iptables -t $table -F
	iptables -t $table -X
	iptables -t $table -Z 
done





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

