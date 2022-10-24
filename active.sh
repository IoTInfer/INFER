#!/bin/bash

# for mac hardcode IFACE
# install gnu-sed > and change to gsed
# change --max-lines to -L1
#brew install iproute2mac gnu-sed nmap arp-scan gawk wget
#replace getent -> arp "$IP" | awk '{print $1}')

#Check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run script using sudo"
  exit
fi

#active fingerprint, populates database.

if [ "$1" = "--portscan" ]  #| echo -e "IP , MAC , VENDOR , HOSTNAME , TCP_PORTS , UDP_PORTS"
then 
  
    IP="$2"
    MAC="$3"
    VENDOR="${4}"
    HOSTNAME="$(getent hosts "$IP" | awk '{print $2}')"
    TCP_PORTS="$(nmap -sT -Pn -n -T4 --min-parallelism 50 --min-rate 1 --open "$IP" | awk 'BEGIN {ORS=","} {if ($2 == "open" || $2 == "filtered")  print gensub("/tcp", "", "g", $1)}')"
    TCP_PORTS="${TCP_PORTS%,}"
    TCP_PORTS="${TCP_PORTS//[^0-9,]/}"
    UDP_PORTS="$(nmap -sU -Pn --max-retries 2  --min-parallelism 50 --max-scan-delay 1ms "$IP"|awk 'BEGIN {ORS=","} {if ($2 == "open" || $2 == "open|filtered" || $2 == "filtered") print gensub("/udp", "", "g", $1)}')"
    UDP_PORTS="${UDP_PORTS%,}"
    UDP_PORTS="${UDP_PORTS//[^0-9,]/}"
    echo "\"$IP\" , \"$MAC\" , \"$VENDOR\" , \"$HOSTNAME\" , \"$TCP_PORTS\" , \"$UDP_PORTS\""
    exit 0
fi


#IFACE="$(ip -o -f inet addr show | awk '/scope global/ {print $2}'|head -1)"
IFACE="$(ip route list | awk '/default/ {print $5}' | head -1")
echo "Interface being used is $IFACE"
echo "Script is running please wait"  

#echo -e "IP , MAC , VENDOR , HOSTNAME , TCP_PORTS , UDP_PORTS"
arp-scan -l -g -I "$IFACE" -F ieee-oui.txt | while read -r -a line 
do 
    IP="${line[0]}"
    [[ "$IP" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] || continue
    MAC="${line[1]}"
    VENDOR="${line[*]:2:5}"
    echo "$IP" "$MAC" "$VENDOR"
done | xargs -P 20 --max-lines=1 "$0" --portscan  | sed -e '1iIP , MAC , VENDOR , HOSTNAME , TCP_PORTS , UDP_PORTS\' | tee ./fingerprints/"FP_$(date +"%m_%d_%I_%M_%p").csv"
echo Done.
