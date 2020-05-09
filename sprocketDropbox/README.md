# Sprocket Dropbox Scripts

### clientAccount.sh

Generate a new key for the customer, for example, generate a key for (ACME Corporation). This scripts will get ran on the server and the keys generated will be saved on the dropbox. 

### dropboxConfig.sh

Configure and install the Kali Linux dropbox machine to be left on the client (ACME Corporation) network. Also has snippets of comments on the top for use later in the configuration. This script is ran on the dropbox itself. 

Be sure to scp the callback keys it generates to the Command and Control server. 

Download the keys from the clientAccount script and put the keys on the dropbox. 

### pentesterConfig.sh

Run this script on the penetration tester's machine. Be sure to copy the penetration testers keys from the server to the penetration tester's machine.

### serverConfig.sh

Configure OpenVPN server (CNC). Also gives the option to generate a new user key for a penetration tester. Furthermore it creates the user "callback". 