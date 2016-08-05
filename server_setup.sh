#!/bin/bash
# Written by Paul Tierlier (Nossie)
#
# Version 0.4
#
# used to change the hostname and ip configuration of a server
#
# Parameters:
# $1 HOSTNAME
# $2 IP ADDRESS
# $3 NETMASK (in CIDR notation)
# $4 DNS 1
# $5 DNS 2
#
#Change DOMAIN.TLD (lines 69, 76 and 87) to reflect your own.

HOSTNAAM=$1
IP=$2
NETMASK=`/usr/bin/ipcalc /$3 |grep Netmask |awk '{print $2}'`
NETWORK="`echo $2| cut -d . -f 1,2,3`.0"
GATEWAY="`echo $2| cut -d . -f 1,2,3`.254"
BROADCAST="`echo $2| cut -d . -f 1,2,3`.255"
DNS1=$4
DNS2=$5
read -r -p "Are You Sure? [y/n] " input
case $input in
    [yY][eE][sS]|[yY])
if [ $# -eq 5 ]
then
        echo "" 
        echo "Here we go..."
        echo "" 
        echo "" 
        echo "Changing the Interface configuration"
        echo "" 
echo "Changing the hostname to $1 "

echo $HOSTNAAM > /etc/hostname
echo ""
echo "Assigning the network configuration:"
echo ""
echo "IP address: $IP/$3"
echo "Gateway $GATEWAY"
echo "DNS Servers $DNS1 // $DNS2"
echo ""
echo ""
cp /etc/network/interfaces /etc/network/interfaces.backup

cat <<EOF > /etc/network/interfaces

# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
        address $IP
        netmask $NETMASK
        network $NETWORK
        broadcast $BROADCAST
        gateway $GATEWAY
        dns-nameservers $DNS1 $DNS2
        dns-search DOMAIN.TLD
EOF

echo "Changing the dns ..."
echo ""

cat <<EOF > /etc/resolv.conf
search DOMAIN.TLD
nameserver $DNS1
nameserver $DNS2
EOF

echo "Adding $1 as hostname to the /etc/hosts file .."
echo ""

echo "" > /etc/hosts
echo "127.0.0.1 localhost" >> /etc/hosts
#echo "$IP $HOSTNAAM" >> /etc/hosts
echo "$IP $HOSTNAAM..DOMAIN.TLD $HOSTNAAM" >> /etc/hosts

echo "Restarting the Network Service, Please connect it using the new IP Address ($IP) ..."

service networking stop
service networking start

else
    echo ""
    echo "Missing parameters"
    echo "" 
    echo "Usage: ./$0 <hostname> <ipaddress> <netmask> <dns1> <dns2>"
    echo "Example: ./$0 nlvmlog09 10.10.10.10 24 10.0.0.3 10.0.0.4"
fi
;;
    [nN][oO]|[nN])
        echo "No"
        echo ""
        echo "Do come back when you are sure ;-)"
            ;;

    *)
    echo "" 
    echo "" 
    echo "Dont know what to do ?"
    echo "" 
    echo "Usage: ./$0 <hostname> <ipaddress> <netmask> <dns1> <dns2>"
    echo "Example: ./$0 debian01  10.10.10.10 24 10.0.0.3 10.0.0.4"

    exit 1
    ;;
esac
