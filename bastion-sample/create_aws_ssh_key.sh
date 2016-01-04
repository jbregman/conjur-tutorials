#!/bin/bash

for i in "$@"
do
case $i in
    -k=*|--key=*)
    KEY_NAME="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--role=*)
    ROLE="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--name=*)
    SUMMON_NAME="${i#*=}"
    shift # past argument=value
    ;;
    *)
            # unknown option
    ;;
esac
done

username=`conjur authn whoami | jsonfield username`


if [[ $ROLE == "" ]]; then

     var_name=`echo $username/aws/keys/$KEY_NAME`
     conjur variable create $var_name
     conjur env run aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text| conjur variable values add $var_name
#     echo $2: !tmp $var_name >> .conjurenv
     conjur resource annotate variable:$var_name description "AWS Key Pair $KEY_NAME"
     conjur resource annotate variable:$var_name summon:name $SUMMON_NAME
     conjur resource annotate variable:$var_name summon:type "!tmp"

else

     echo "Creating key for role $ROLE"
     var_name=`echo $COLLECTION/aws/role/$ROLE/keys/$KEY_NAME`
     conjur variable create --as-role policy:$COLLECTION/aws/role/$ROLE $var_name
     conjur env run aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text| conjur variable values add $var_name


	conjur resource permit variable:$COLLECTION/aws/role/$ROLE/keys/$KEY_NAME group:$COLLECTION/aws/role/$ROLE/readers read
	conjur resource permit variable:$COLLECTION/aws/role/$ROLE/keys/$KEY_NAME group:$COLLECTION/aws/role/$ROLE/updaters read
	conjur resource permit variable:$COLLECTION/aws/role/$ROLE/keys/$KEY_NAME group:$COLLECTION/aws/role/$ROLE/readers execute 
	conjur resource permit variable:$COLLECTION/aws/role/$ROLE/keys/$KEY_NAME group:$COLLECTION/aws/role/$ROLE/updaters update 
     
     #echo $2: !tmp $var_name >> .conjurenv
     conjur resource annotate variable:$var_name description "AWS Key Pair $KEY_NAME"
     conjur resource annotate variable:$var_name summon:name $SUMMON_NAME
     conjur resource annotate variable:$var_name summon:type "!tmp"
fi

