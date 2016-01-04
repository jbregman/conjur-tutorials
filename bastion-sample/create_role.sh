#!/bin/bash



role=$1
role_policy=$2
conjur_group=$3

echo "Loading role in collection $COLLECTION"

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

export ROLE_ARN=`aws iam get-role --role-name $1 | jsonfield Role.Arn`

# Add the AWS IAM role to the Policy
policy_name=`echo conjur_$3`
aws iam put-role-policy --role-name $1 --policy-name $policy_name --policy-document file://$2

# Create the role in conjur
export AWS_ROLE=$1
export AWS_POLICY=`cat $2`

conjur policy load --as-group $3 --collection $COLLECTION -c $1_role.json aws_role_policy.rb 

#Write the .conjurenv
#echo AWS_ACCESS_KEY_ID: !var $COLLECTION/aws/role/$1/AccessKeyId > .$1.conjurenv
#echo AWS_SECRET_ACCESS_KEY: !var $COLLECTION/aws/role/$1/SecretAccessKey >> .$1.conjurenv
#echo AWS_SESSION_TOKEN: !var $COLLECTION/aws/role/$1/SessionToken >> .$1.conjurenv
