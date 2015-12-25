#bastion
This is a sample that configures an AWS VPC with a public and private subnet protected by Conjur.
## Set-up the Environment
1. Install the [Conjur CLI](https://developer.conjur.net/cli)
2. Install the [Amazon CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

## Create the Users and Groups in Conjur
```
conjur user create --as-group=security_admin --uidnumber=34 -p david.ortiz
ssh-keygen -t rsa -b 4096 -C "david.ortiz@example.com"
conjur pubkeys add david.ortiz @david.ortiz.pub
conjur group create --as-group=security_admin --gidnumber=12345 aws_admin
conjur group members add -a aws_admin david.ortiz
conjur authn login david.ortiz
```
## Load the Conjur Policy
```
conjur policy load --as-group aws_admin --collection example -c bastion.json bastion_policy.rb
conjur group members add example/bastion/v1/admins group:aws_admin
```
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
## Load SSH Keys into Conjur
The bastion cloud formation template uses 2 key-pairs as parameters - one for the private subnet and one for the public subnet.  You can creates the keys in Conjur and AWS by running the following commands:
```
./create_aws_ssh_key.sh demo_public_key PUBLIC_SSH_KEY
./create_aws_ssh_key.sh demo_private_key PRIVATE_SSH_KEY
```
The script also updates the references to the SSH keys in the **.conjurenv**
```
PUBLIC_SSH_KEY: !tmp /david.ortiz/aws/key/demo_public_key
PRIVATE_SSH_KEY: !tmp /david.ortiz/aws/key/demo_private_key
```
## Launch the Cloud Formation Template
Now the Cloud Formation Template can be started.  
```
conjur env run aws cloudformation create-stack --stack-name ExampleBastion --template-body file://bastion \
--parameters ParameterKey=PublicSubnetKeyParameter,ParameterValue=demo_public_key \
ParameterKey=PrivateSubnetKeyParameter,ParameterValue=demo_private_key
```
Once the stack has started, you can ssh to the bastion using the public ssh key
```
conjur env run ./ssh_to_bastion.sh ExampleBastion
```
Exit out of the bastion
```
ubuntu@ip-10-0-1-XXX:~$exit
```
##Conjurize the Bastion
This command configures the bastion with the Conjur identity *bastion1.example.com*
```
conjur host create bastion1.example.com |tee bastion1.json | conjurize --ssh --sudo | conjur env run ./ssh_to_bastion.sh ExampleBastion
```
And add the host to the layer
```
conjur layer hosts add example/bastion/v1 bastion1.example.com

```
