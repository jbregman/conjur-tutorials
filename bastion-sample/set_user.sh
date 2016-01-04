#! /bin/bash

for i in "$@"
do
case $i in
    -u=*|--user=*)
    CONJUR_USER="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--role=*)
    ROLE="${i#*=}"
    shift # past argument=value
    ;;
    *)
            # unknown option
    ;;
esac
done


current_user=`conjur authn whoami | jsonfield username`


	

if [ "$current_user" != "$CONJUR_USER" ]; then
	if [ "$CONJUR_USER" != "" ]; then
		conjur authn login $CONJUR_USER
	else
		echo "$current_user is already logged in"
		CONJUR_USER=$current_user
	fi	
else
	echo "$CONJUR_USER is already logged in"
fi

conjur_account=`conjur authn whoami | jsonfield account`

export ROLE=$ROLE
export CONJUR_USER=$CONJUR_USER
export CONJUR_ACCOUNT=$conjur_account
conjur script execute get_conjurenv.rb 

conjur env check
