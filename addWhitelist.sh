#!/bin/bash

i=1

fileLength=$(wc -l < whitelist.txt)

while [ $i -lt $((fileLength)) ]
do
domain=$(sed "${i}q;d" whitelist.txt)
pihole -w -nr $domain
i=$[$i+1]
done

pihole restartdns

echo "Finished"
echo ""
echo "Press ENTER to restart"
read INPUT
systemctl reboot -i
