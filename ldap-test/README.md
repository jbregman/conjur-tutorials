#ldap-test

## Set-up the Environment

create a file called policy.json:

{
     "collection":"development",
     "version":"1.0"
}

run the script to set-up the environment

set_conjur_env.sh

## build the docker file

sudo docker build -t tomcatldap:1.0 .

## start the docker container

./run.sh

