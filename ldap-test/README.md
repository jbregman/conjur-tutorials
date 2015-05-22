#ldap-test

0.  export CONJUR_COLLECTION=development
1.  export CONJUR_POLICY_VERSION=1.0
2.  export CONJUR_LDAP_POLICY=$CONJUR_COLLECTION/ldap-$CONJUR_POLICY_VERSION
3.  Create the host tomcat - conjur host create $CONJUR_POLICY/tomcat | tee tomcat.json
4.  Load the policy

$conjur policy load --as-group security_admin --collection $CONJUR_COLLECTION ldap.json ldap.rb

5.  Test with the .sh

[vagrant@localhost ldap-test]$ sudo docker run -it -v $PWD/tomcat-users.xml:/us
r/local/tomcat/conf/tomcat-users.xml -v $PWD/server.xml:/usr/local/tomcat/conf/
server.xml -v $PWD/conjurize.sh:/conjurize.sh -v $PWD/ldap.conf:/etc/ldap/ldap.
conf --rm -p 8080:8080 tomcatldap:1.0
