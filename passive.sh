#!/bin/bash

#Check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run script using sudo"
  exit
fi


sudo tcpdump -lenx -i eth0 -s 1500 port bootps or port bootpc  &>/dev/null & 
sudo dhcpdump -i eth0 | tee ./fingerprints/dhcp_$(date +"%m_%d_%I_%M_%p").txt  &
