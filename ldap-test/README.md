#ldap-test

## Set-up the Environment

create a file called policy.json:
```
{
     "collection":"development",
     "version":"1.0"
}
```
run the script to set-up the environment
```
set_conjur_env.sh
```
## test the LDAP connection
This will run the samples described at https://developer.conjur.net/reference/services/ldap

NOTE: BEFORE you run this make sure you've added the information in my_ldap.conf to you openldap client configuration, otherwise the LDAPS connection to the conjur server will FAIL

## build the docker file

sudo docker build -t tomcatldap:1.0 .

## start the docker container

./run.sh

