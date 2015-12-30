#! /bin/bash

if [ "$2" != "--no-login" ]; then
	conjur authn login $1 
        ln -Fs .$1.conjurenv .conjurenv
	echo Conjur user profile set to $1
else 
	new_env_file="$(mktemp /tmp/conjur.XXXXX)"
        username=`conjur authn whoami | jsonfield username`		
	
	cat .$username.conjurenv > $new_env_file
	cat .$1.conjurenv >> $new_env_file
	ln -Fs $new_env_file .conjurenv
	echo Conjur user profile set to $username with aws_role $1
	
fi
conjur env check
