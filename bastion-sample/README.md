#bastion
This is a sample that configures an AWS VPC with a public and private subnet protected by Conjur.
## Set-up the Environment
1. Install the [Conjur CLI](https://developer.conjur.net/cli)
2. Install the [Amazon CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
3. Set the Conjur Collection.  
```
export COLLECTION=example
```

## Create the AWS Administration User and Group
The bastion in the public subnet is the gateway to the private subnet.  Access to the bastion is controlled by Conjur.  In this example, there is a group called *aws:admin*.  This group configures the policies for the bastion and has sudo privileges on the bastion.  The commands below create a user named *david.ortiz*.Users need their own SSH key to access the bastion.  The *create_user.sh* command stores the keys in Conjur.  There is no need to further secure the private key file.
```
./create_user.sh david.ortiz 34
conjur group create --as-group=security_admin --gidnumber=12345 aws_admin
conjur group members add -a aws_admin david.ortiz
./set_user.sh david.ortiz
```

The *set_user.sh* command logs the user into Conjur and maps **.conjurenv** to the user's credentials. The **.conjurenv** file should look like this
```
SSH_KEY: !tmp david.ortiz/personal/key
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
conjur env run ./create_role.sh bastion-admin aws_admin full_access_policy.json

```
Now that the role has been created, create a temporary session 
```
conjur env run ./create_aws_key_for_role.sh bastion-admin
```
And finally, switch context to the role
```
./set-user.sh bastion-admin --no-login
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
## Load the Conjur Policy
```
conjur policy load --as-group aws_admin --collection $COLLECTION -c bastion.json bastion_policy.rb
conjur group members add example/bastion/v1/admins group:aws_admin
```
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
conjur env run ./ssh_to_bastion.sh ExampleBastion --me
```
