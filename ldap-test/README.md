#ldap-test

0.  export CONJUR_COLLECTION=development
1.  export CONJUR_POLICY_VERSION=1.0
2.  export CONJUR_LDAP_POLICY=$CONJUR_COLLECTION/ldap-$CONJUR_POLICY_VERSION
3.  Create the host tomcat - conjur host create $CONJUR_POLICY/tomcat | tee tomcat.json
4.  Load the policy

$conjur policy load --as-group security_admin --collection $CONJUR_COLLECTION ldap.json ldap.rb

5.  Get the keys that were created for the host and the kevin user by running the set-env.sh.  This generates myenv.sh.  Add the variables into the environment:

. ./myenev.sh

6.  Test the ldap connection with the ldap-test.sh $HOST_API_KEY $KEVIN_API_KEY

7.  conjurize the host - cat tomcat.json | conjurize | conjurize.sh

8.  start the docker container

[vagrant@localhost ldap-test]$ sudo docker run -it -v $PWD/tomcat-users.xml:/us
r/local/tomcat/conf/tomcat-users.xml -v $PWD/server.xml:/usr/local/tomcat/conf/
server.xml -v $PWD/conjurize.sh:/conjurize.sh -v $PWD/ldap.conf:/etc/ldap/ldap.
conf --rm -p 8080:8080 tomcatldap:1.0


