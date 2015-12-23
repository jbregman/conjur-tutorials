#bastion

This is a sample that configures an AWS VPC with a public and private subnet protected by Conjur.

## Set-up the Environment

Install the [Conjur CLI](https://developer.conjur.net/cli)

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

