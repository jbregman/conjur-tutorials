#bastion
This is a sample that configures an AWS VPC with a public and private subnet protected by Conjur.
## Set-up the Environment
1. Install the [Conjur CLI](https://developer.conjur.net/cli)
2. Install the [Amazon CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
3. Log into Conjur as a member of the security_admin role (e.g. admin)
4. Set the Conjur Collection.  
```
export COLLECTION=example
```
##Overview
This sample deloys a bastion on a public subnet protecting access to systems running on a private subnet.  Access to the bastion is controlled by Conjur.  From the bastion, some users are authorized to manage the AWS deployment via the AWS CLI.  This is a more scalable and simpler model than managing AWS via the management console, because it dramatically simplifies the application of AWS IAM roles.

This sample has four groups of users
- AWS Administrator (aws_admin) - Set-up the AWS infrastructure including the bastion and control access to it via Conjur.  They have root priviledges on the bastion
- Bastion Managers (bastion_manager) -  Configure the bastion for use by other users.  They have root access to the bastion.
The bastion in the public subnet is the gateway to the private subnet.  
- Bastion Users (bastion_user) - Connect to the bastion and manage AWS via the AWS CLI.  They have regular user access to the bastion
- AWS Users - (aws_user) - Connect via the bastion to AWS infrastructure provisioned by the bastion_users

## Create the Users and Groups in Conjur

Users need their own SSH key to access the bastion.  The *create_user.sh* command creates the keys and stores thems in Conjur.  Only the user has access to the keys, so its safe to store them in Conjur.  
```
./create_user.sh david.ortiz 34 security_admin
conjur group create --as-group=security_admin --gidnumber=12345 aws_admin
conjur group members add -a aws_admin david.ortiz
# Allow the aws_admin to add public keys for other users
conjur resource permit service:pubkeys-1.0/public-keys group:aws_admin update
./set_user.sh david.ortiz
```

The *set_user.sh* command logs the user into Conjur and maps **.conjurenv** to the user's credentials. The **.conjurenv** file should look like this
```
SSH_KEY: !tmp david.ortiz/personal/key
```

The rest of the users and groups will be created by the aws_admin (david.ortiz)
```
# Set-up the Bastion Manager
./create_user.sh ted.williams 7 aws_admin
conjur group create --as-group=aws_admin --gidnumber=12346 bastion_manager
conjur group members add -a bastion_manager ted.williams

# Set-up the Bastion User
./create_user.sh jerry.remy 2 aws_admin
conjur group create --as-group=aws_admin --gidnumber=12347 bastion_user
conjur group members add -a bastion_user jerry.remy

# Set-up the AWS User
./create_user.sh pedro.martinez 45 aws_admin
conjur group create --as-group=aws_admin --gidnumber=12348 aws_user
conjur group members add -a aws_user pedro.martinez
```
## Load AWS Credentials into Conjur
When you [create access keys](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) for AWS, you have the option to download them to a local file.  By loading the credentials into Conjur, the credentials will be secure, and you can remove the .csv.
```
./load_aws_credentials.rb path_to_credentials_file > .conjurenv
```
This creates a **.conjurenv** that references the credentials and will pass them into the environment for the AWS CLI. The **.conjurenv** file should now have the AWS credentials and the SSH key referenced.
```
SSH_KEY: !tmp david.ortiz/personal/key
AWS_ACCESS_KEY_ID: !var david.ortiz/aws/credentials/AccessKeyId
AWS_SECRET_ACCESS_KEY: !var david.ortiz/aws/credentials/SecretAccessKey
```
More information on the **.conjurenv** file can be found on the [Conjur Developer Site]( https://developer.conjur.net/reference/tools/utilities/conjurenv)

You can test the set-up by running the following command
```
conjur env run aws ec2 describe-regions
```
## Create IAM Role for the AWS Administrator's Group
AWS has the ability to define specific temporary credentials tied to an IAM role.  This is the preferred way to access AWS as it eliminates the need to share priviledged credentials and limits the time and scope of the credentials. In this example, the administrator is going to set-up the IAM role in AWS and create a corresponding policy in Conjur.

```
conjur env run ./create_role.sh aws_admin full_access_policy.json aws_admin
```
Now that the role has been created, create a temporary session 
```
conjur env run ./create_aws_key_for_role.sh aws_admin
```
And finally, switch context to the role
```
./set_user.sh aws_admin --no-login
```

## Load SSH Keys into Conjur
The bastion cloud formation template uses 2 key-pairs as parameters - one for the private subnet and one for the public subnet.  You can creates the keys in Conjur and AWS by running the following commands:
```
./create_aws_ssh_key.sh demo_public_key PUBLIC_SSH_KEY
./create_aws_ssh_key.sh demo_private_key PRIVATE_SSH_KEY
```
The script also updates the references to the SSH keys in the **.conjurenv**
```
PUBLIC_SSH_KEY: !tmp example/aws/role/bastion-admin/keys/demo_public_key
PRAIVTE_SSH_KEY: !tmp example/aws/role/bastion-admin/keys/demo_private key
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
## Load the Conjur Policy
The policy defines the layer (group of hosts) for the bastion and 2 groups (*admin* - root users, *users* - non-root users) and their permissions
```
conjur policy load --as-group aws_admin --collection $COLLECTION -c bastion.json bastion_policy.rb
```
The following commands assign the groups the permissions on the bastion
```
## Root Access
conjur group members add $COLLECTION/bastion/v1/admins group:bastion_manager
## Non-Root Access
conjur group members add $COLLECTION/bastion/v1/users group:bastion_user
conjur group members add $COLLECTION/bastion/v1/users group:aws_user
```
There is no need to grant the aws_admin group permissions, because they are the owner of the host, and therefore have full permission
##Conjurize the Bastion
This command configures the bastion with the Conjur identity *bastion1.example.com*
```
conjur host create --as-group aws_admin bastion1.example.com |tee bastion1.json | conjurize --ssh --sudo | conjur env run ./ssh_to_bastion.sh ExampleBastion
```
And add the host to the layer
```
conjur layer hosts add example/bastion/v1 bastion1.example.com
```
Now, connect to the bastion as david.ortiz
```
./set-user.sh david.ortiz
conjur env run ./ssh_to_bastion.sh ExampleBastion --me
```
