#!/bin/bash
rm `pwd`/cve.csv
wget https://www.computec.ch/projekte/vulscan/download/cve.csv
rm `pwd`/exploitdb.csv
wget https://www.computec.ch/projekte/vulscan/download/exploitdb.csv
rm `pwd`/openvas.csv
wget https://www.computec.ch/projekte/vulscan/download/openvas.csv
rm `pwd`/osvdb.csv
wget https://www.computec.ch/projekte/vulscan/download/osvdb.csv
rm `pwd`/scipvuldb.csv
wget https://www.computec.ch/projekte/vulscan/download/scipvuldb.csv
rm `pwd`/securityfocus.csv
wget https://www.computec.ch/projekte/vulscan/download/securityfocus.csv
rm `pwd`/securitytracker.csv
wget https://www.computec.ch/projekte/vulscan/download/securitytracker.csv
rm `pwd`/xforce.csv
wget https://www.computec.ch/projekte/vulscan/download/xforce.csv
