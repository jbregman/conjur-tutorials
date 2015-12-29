#!/bin/bash

role=$1
role_policy=$2
conjur_group=$3

aws_user=`aws iam get-user | jsonfield User.Arn`
echo $aws_user

assume_policy="$(mktemp /tmp/conjur.XXXXX)"
cat <<EOF >> $assume_policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "$aws_user"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

EOF

echo $assume_policy

# Create the IAM role in AWS
aws iam create-role --role-name $1 --assume-role-policy-document file://$assume_policy

# Add the AWS IAM role to the Policy
policy_name=`echo conjur_$3`
aws iam put-role-policy --role-name $1 --policy-name $policy_name --policy-document file://$2

# Create the role in conjur
conjur role create --as-group $3 role:aws/$1

# Create the variables used to store the AWS temporary creds
conjur variable create --as-role role:aws/$1 aws/$1/AccessKeyId
conjur variable create --as-role role:aws/$1 aws/$1/SecretAccessKey
conjur variable create --as-role role:aws/$1 aws/$1/SessionToken


