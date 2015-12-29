#! /bin/bash

#conjur_username=`conjur authn whoami | jsonfield username`
profile_regex="\.(.*)\.conjurenv"
conjur_profile=`readlink .conjurenv`

[[ $conjur_profile =~ $profile_regex ]]
role_name=${BASH_REMATCH[1]}
echo $role_name 

