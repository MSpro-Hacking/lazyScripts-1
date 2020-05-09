#!/bin/bash
#Run chmod u+x autoSnapper.sh
#Example Cron: * * * * * ~/.scripts/autoSnapper.sh
#From: https://www.techrepublic.com/article/how-to-automate-virtualbox-snapshots-with-the-vboxmanage-command/
​NOW=`date +"%m-%d-%Y%T"`
​SNAPSHOT_NAME="$NOW"
​SNAPSHOT_DESCRIPTION="Snapshot taken on $NOW"

VBoxManage snapshot {VirtualMachineName} take "$SNAPSHOT_NAME" --description "$SNAPSHOT_DESCRIPTION"