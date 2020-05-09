#!/bin/bash
# Install to make files for RF stuff for the HackRF to sniff GSM

echo ""

# Verify we are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

apt update -y
apt upgrade -y 
apt dist-upgrade -y 
apt autoremove -y
apt autoclean -y
apt install wireshark -y
apt install gnuradio gnuradio-dev gr-osmosdr gr-osmosdr gqrx-sdr wireshark -y
apt install git cmake libboost-all-dev libcppunit-dev swig doxygen liblog4cpp5-dev python-scipy -y
git clone https://github.com/ptrkrysik/gr-gsm.git
(cd gr-gsm && mkdir build && cd build && cmake .. && make && make install)
sudo ldconfig
touch ~/.gnuradio/config.conf
echo "[grc]" >> ~/.gnuradio/config.conf
echo "local_blocks_path=/usr/local/share/gnuradio/grc/blocks" >> ~/.gnuradio/config.conf
git clone https://github.com/scateu/kalibrate-hackrf.git
(cd kalibrate-hackrf && ./bootstrap && ./configure && make && make install)
echo "[+] Done"