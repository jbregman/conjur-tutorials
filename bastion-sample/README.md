#bastion

This is a sample that configures an AWS VPC with a public and private subnet protected by Conjur.

## Set-up the Environment

Install the [Conjur CLI](https://developer.conjur.net/cli)

Install the [Amazon CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

## Load AWS Credentials into Conjur

When you [create access keys](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) for AWS, you have the option to download them to a local file.  By loading the credentials into Conjur, the credentials will be secure, and you can remove the .csv.

```
./load_aws_credentials.rb path_to_credentials_file > .conjurenv
```
This creates a **.conjurenv** that references the credentials and will pass them into the environment for the AWS CLI. 

```
AWS_ACCESS_KEY_ID: !var jbregman/aws_key
AWS_SECRET_ACCESS_KEY: !var jbregman/aws_secret
```
More information on the **.conjurenv** file can be found on the [Conjur Developer Site]( https://developer.conjur.net/reference/tools/utilities/conjurenv)

You can test the set-up by running the following command
```
conjur env run aws ec2 describe-regions
```

