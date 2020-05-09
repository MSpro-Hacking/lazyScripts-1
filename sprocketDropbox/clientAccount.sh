#!/bin/bash
# Generate a new key for a client, run this on the Server, these keys get saved to the dropbox
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "[+] Please enter the clients name"
read clientName
echo "SIGN YOUR CERT, hit ENTER to continue"
read INPUT
(cd /etc/openvpn/easy-rsa ; source vars ; ./build-key $clientName)
touch /etc/openvpn/ccd/$clientName
echo "# Client networks we want to route through the dropbox" > /etc/openvpn/ccd/$clientName
echo "[+] Enter the routes for the client in /etc/openvpn/ccd/$clientName"