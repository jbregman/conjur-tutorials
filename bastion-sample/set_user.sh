#! /bin/bash

conjur authn login $1 
ln -Fs .$1.conjurenv .conjurenv
echo Conjur user profile set to $1

