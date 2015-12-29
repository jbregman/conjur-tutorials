#! /bin/bash

if [ "$2" != "--no-login" ]; then
	conjur authn login $1 
fi
ln -Fs .$1.conjurenv .conjurenv
echo Conjur user profile set to $1
conjur env check
