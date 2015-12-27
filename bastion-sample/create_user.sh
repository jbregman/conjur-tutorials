#! /bin/bash

# This script creates a user in Conjur including a public private key/pair for SSH
# The first parameter is the name of the user (e.g. larry.bird)
# The second parameter is the uid (e.g 33)
conjur user create --as-group=security_admin --uidnumber=$2 -p $1
# The address is required for the ssh certificate
address=`echo $1@example.com` 
# This command will create a private key at $1 and a public key at $1.pub
ssh-keygen -t rsa -b 4096 -C $address -f $1 
# Add the public key to the user in Conjur
conjur pubkeys add $1 @$1.pub
# The name of the varibale in Conjur (e.g. larry.bird/personal/key)
var_name=`echo $1/personal/key`
# Creates the variable
conjur variable create $var_name
# This is very clever - you pipe the private key in and store the value in Conjur
cat $1 |conjur variable values add $var_name
# Updates the .conjurenv with a refernce to be used by other scripts
echo MY_SSH_KEY: !tmp $var_name >> .conjurenv
# Clean up the public and private keys.  They are stored in Conjur
rm $1
rm $1.pub

