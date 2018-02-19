#!/bin/sh

# PARA HACER PERMANENTE!:
# iptables-save > /etc/iptables/iptables.rules



com='-m comment --comment'

# FLUSH
iptables -F

#--- Chains ----------------------------------------------------------------------------
iptables -N TCP
iptables -N UDP
iptables -N VPN


#--- INCOMING --------------------------------------------------------------------------
iptables -A INPUT -m conntrack	--ctstate RELATED,ESTABLISHED			-j ACCEPT	$com	"Conexiones ya existentes y relaccionadas"
iptables -A INPUT -i lo								-j ACCEPT	$com	"Loopback"
iptables -A INPUT -m conntrack	--ctstate INVALID 				-j DROP 	$com	"Drop paquetes invalidos" #Es necesaria??
iptables -A INPUT -p icmp	--icmp-type 8 -m conntrack --ctstate NEW 	-j ACCEPT 	$com  	"Se procesan PING"
iptables -A INPUT -p udp	-m conntrack --ctstate NEW			-j UDP 		$com	"Manda a cadena UDP"
iptables -A INPUT -p tcp	--syn -m conntrack --ctstate NEW 		-j TCP 		$com	"Manda a cadena TCP"
iptables -A INPUT -i tun+ 	-m conntrack --ctstate NEW			-j VPN		$com    "Manda a cadena VPN"
#iptables -A INPUT -j REJECT --reject-with icmp-proto-unreach 					$com	"Rechazar en lugar de drop"


#--- TCP -------------------------------------------------------------------------------
iptables -A TCP -p tcp --dport 22		-j ACCEPT	$com	"SSH" #Comentado para utilizar portknocking
iptables -A TCP -p tcp --dport 80		-j ACCEPT	$com	"PORT 80 for web server"
iptables -A TCP -p tcp --dport 443		-j ACCEPT	$com    "PORT 443 for SSL (https) web server"
iptables -A TCP -p tcp --dport 10011		-j ACCEPT	$com	"Team Speak 3 Server: Query Port"
iptables -A TCP -p tcp --dport 30033 		-j ACCEPT	$com	"Team Speak 3 Server: File Transfer"
iptables -A TCP -p tcp --dport 40000:40010 	-j ACCEPT	$com    "Deluge"
iptables -A TCP -p tcp --dport 8112 		-j ACCEPT	$com    "Deluge-web"
iptables -A TCP -p tcp --dport 58846		-j ACCEPT	$com    "Deluge-daemon"
iptables -A TCP -p tcp --dport 3306		-j ACCEPT	$com    "MariaDB"
iptables -A TCP -p tcp --dport 53		-j ACCEPT	$com	"unbound DNS server"
#iptables -A TCP -p tcp --dport 8000		-j ACCEPT	$com    "Kodi Mediacenter"
#iptables -A TCP -p tcp --dport 4040		-j ACCEPT	$com    "Subsonic"
#iptables -A TCP -p tcp --dport 8443		-j ACCEPT	$com    "Subsonic HTTPS"
#iptables -A TCP -p tcp --dport 21		-j ACCEPT	$com    "FTP Commands"
#iptables -A TCP -p tcp --dport 40011:40019	-j ACCEPT	$com    "FTP Data"
#iptables -A TCP -p tcp --dport 10000		-j ACCEPT	$com    "UNISON"
#iptables -A TCP -p tcp --dport 45000		-j ACCEPT	$com    "jFileSync"
iptables -A TCP -p tcp --dport 8096		-j ACCEPT	$com	"emby htpp"
iptables -A TCP -p tpc --dport 8020		-j ACCEPT	$com	"emby https"


#Otros paquetes TCP:
iptables -A TCP -p tcp	--dport 2869 		-j ACCEPT						$com    "UPnP"
iptables -A TCP -p tcp ! --syn 				-j REJECT --reject-with tcp-rst	$com	"Paquetes importantes que no deben ser dropeados, sino rechazados"


#--- UDP -------------------------------------------------------------------------------

iptables -A UDP -p udp --dport 9987		-j ACCEPT	$com	"Team Speak 3 Server"
iptables -A UDP -p udp --dport 40000:40010	-j ACCEPT	$com    "Deluge"    
iptables -A UDP -p udp --dport 58846		-j ACCEPT	$com    "Deluge-daemon"
iptables -A UDP -p udp --dport 123		-j ACCEPT	$com	"Network Time Protocol"
iptables -A UDP -p udp --dport 53		-j ACCEPT	$com	"unbound DNS server"
#iptables -A UDP -p udp --dport 1194		-j ACCEPT	$com    "openVPN@server (configurado para UDP)"
#iptables -A UDP -p udp --dport 9777		-j ACCEPT	$com    "Kodi Mediacenter event center"

#Otros paquetes UDP
#iptables -A UDP -p udp --dport 1900		-j ACCEPT	$com    "UPnP"



#--- VPN -------------------------------------------------------------------------------
#iptables -A FORWARD -i tun+ -o eht0					-j ACCEPT		$com	"VPN in-out. Unir VPN y LAN"
#iptables -A FORWARD -i eth0 -o tun+					-j ACCEPT		$com    "VPN in-out. Unir VPN y LAN"
#iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0	-j MASQUERADE	$com    "VPN"

#Accesibles solo desde VPN:
#iptables -A VPN -i tun+ -p tcp --dport 8112			-j ACCEPT		$com    "Deluge WEB"



#--- Configurar chains -----------------------------------------------------------------
iptables -P FORWARD	DROP
iptables -P OUTPUT	ACCEPT
iptables -P INPUT	DROP



### EOF ###

