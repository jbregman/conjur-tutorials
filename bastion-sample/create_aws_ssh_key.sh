#!/bin/bash


username=`conjur authn whoami | jsonfield username`
var_name=`echo $username/aws/keys/$1`

conjur variable create $var_name

conjur env run aws ec2 create-key-pair --key-name $1 --query 'KeyMaterial' --output text| conjur variable values add $var_name

echo $2: !tmp $var_name >> .conjurenv
