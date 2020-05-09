#!/bin/bash
workingDirectory=$(pwd)
echo "[+] We are currently in $workingDirectory"
echo ""
echo "[+] Waiting for 3 seconds..."
sleep 3
echo "[+] Making directory for Phrack Magazine"
mkdir phrackMagazine
echo "[+] Downloading All Phrack Archives"
wget -r --no-parent --reject="index.html*" http://www.phrack.org/archives/tgz/
numberOfFiles=$(ls -l $workingDirectory/www.phrack.org/archives/tgz | wc -l)
fileCountActual=$(expr $numberOfFiles - 1)
echo ""
echo "[+] Current number of issues: $fileCountActual" 
echo ""
echo "[+] Sleeping for 3 seconds..."
sleep 3
mv $workingDirectory/www.phrack.org/archives/tgz/* $workingDirectory/phrackMagazine/
rm -rf $workingDirectory/www.phrack.org
for ((i=1; i<=fileCountActual; i++))
do
	DIRECTORY="phrack$i"
	mkdir $DIRECTORY
done

for ((i=1; i<=fileCountActual; i++))
do
	FILE="phrack$i.tar.gz"
	DIRECTORY="phrack$i"
	tar xvzf phrackMagazine/$FILE -C $workingDirectory/$DIRECTORY
	rm -rf phrackMagazine/$FILE
done

for ((i=1; i<=fileCountActual; i++))
do
	mv $workingDirectory/phrack$i $workingDirectory/phrackMagazine
done

echo "[+] DONE [+]"