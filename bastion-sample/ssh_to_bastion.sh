#!/bin/bash
instance_id=`aws cloudformation describe-stack-resources --stack-name $1 | jsonfield StackResources.1.PhysicalResourceId`

ip_address=`aws ec2 describe-instances --instance-id $instance_id | jsonfield Reservations.0.Instances.0.PublicIpAddress`
 
eval $(ssh-agent)
if [ "$2" = "--me" ]; then
     username=`conjur authn whoami | jsonfield username`
     ssh-add $MY_SSH_KEY
     ssh $username@$ip_address
else
     ssh-add $PUBLIC_SSH_KEY
     ssh ubuntu@$ip_address 
fi

