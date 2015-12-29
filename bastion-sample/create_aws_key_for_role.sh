#!/bin/bash
role_arn=`aws iam get-role --role-name $1 | jsonfield Role.Arn`
session_info=`aws sts assume-role --role-arn $role_arn --role-session-name testsession1`
secret_access_key=`echo $session_info | jsonfield Credentials.SecretAccessKey`
session_token=`echo $session_info | jsonfield Credentials.SessionToken`
access_key_id=`echo $session_info | jsonfield Credentials.AccessKeyId`

echo $secret_access_key | conjur variable values add example/bastion/v1/aws/SecretAccessKey
echo $session_token | conjur variable values add example/bastion/v1/aws/SessionToken
echo $access_key_id | conjur variable values add example/bastion/v1/aws/AccessKeyId


echo 'AWS_ACCESS_KEY_ID: !var example/bastion/v1/aws/AccessKeyId' > $1.conjurenv
echo 'AWS_SECRET_ACCESS_KEY: !var example/bastion/v1/aws/SecretAccessKey' >> $1.conjurenv
echo 'AWS_SESSION_TOKEN: !var example/bastion/v1/aws/SessionToken' >> $1.conjurenv
