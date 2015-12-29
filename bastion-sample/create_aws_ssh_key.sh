#!/bin/bash


username=`conjur authn whoami | jsonfield username`
profile=`./get_user.sh`

if [ "$username" == "$profile" ]; then

     var_name=`echo $username/aws/keys/$1`
     conjur variable create $var_name
     conjur env run aws ec2 create-key-pair --key-name $1 --query 'KeyMaterial' --output text| conjur variable values add $var_name
     echo $2: !tmp $var_name >> .conjurenv

else

     echo "Creating key for role $profile"
     var_name=`echo $COLLECTION/aws/role/$profile/keys/$1`
     conjur variable create --as-role policy:$COLLECTION/aws/role/$profile $var_name
     conjur env run aws ec2 create-key-pair --key-name $1 --query 'KeyMaterial' --output text| conjur variable values add $var_name


	conjur resource permit variable:$COLLECTION/aws/role/$profile/keys/$1 group:$COLLECTION/aws/role/$profile/readers read
	conjur resource permit variable:$COLLECTION/aws/role/$profile/keys/$1 group:$COLLECTION/aws/role/$profile/updaters read
	conjur resource permit variable:$COLLECTION/aws/role/$profile/keys/$1 group:$COLLECTION/aws/role/$profile/readers execute 
	conjur resource permit variable:$COLLECTION/aws/role/$profile/keys/$1 group:$COLLECTION/aws/role/$profile/updaters update 
     
     echo $2: !tmp $var_name >> .conjurenv
fi

