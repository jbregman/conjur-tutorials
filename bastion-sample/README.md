#bastion

This is a sample that configures an AWS VPC with a public and private subnet protected by Conjur.

## Set-up the Environment

```
./load_aws_credentials.rb path_to_credentials_file > .conjurenv
```
This creates a **.conjurenv** that references the credentials and will pass them into the environment for the AWS CLI.  You can test the set-up by running the following command
```
conjur env run aws ec2 describe-regions
```

