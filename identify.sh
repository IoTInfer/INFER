#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run script using sudo"
  exit
fi

#os detect
#install dependencies 


chmod a+x ./active.sh
chmod a+x ./passive.sh

mkdir fingerprints

#If MacOS to get IP dependency
#brew install iproute2mac gnu-sed nmap arp-scan gawk wget dhcpdump 

#Downloads Dependencies
sudo apt-get install wget nmap tcpdump dhcpdump arp-scan sed gawk

#Downloads IEE database
wget -nc --level=1 https://raw.githubusercontent.com/royhills/arp-scan/master/ieee-oui.txt .

#Scans three time 
for i in {1..3}; do ./active.sh; done

echo "Active Scanning Completed"
echo "The next step requires you to power cycle your router."
read -p "Press enter to continue"


#sh ./passive.sh

echo Done.
