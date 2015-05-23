echo $CONJUR_HOST
export TOMCAT_HOST=$CONJUR_COLLECTION/ldap-$CONJUR_POLICY_VERSION/tomcat
echo "Tomcat host:" $TOMCAT_HOST
echo "Account: " $CONJUR_ACCOUNT
echo HOST_API_KEY=$1
echo KEVIN_API_KEY=$2



ldapsearch -H ldaps://$CONJUR_HOST \
  -D uid=$TOMCAT_HOST,ou=host,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur \
  -w $1 \
  -b "ou=user,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur"

echo ===========================================1
ldapsearch -H ldaps://$CONJUR_HOST \
  -D uid=$TOMCAT_HOST,ou=host,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur \
  -w $1 \
  -b "ou=group,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur"
echo ===========================================================2
ldapsearch -H ldaps://$CONJUR_HOST \
  -D uid=kevin@$CONJUR_COLLECTION-ldap-$CONJUR_POLICY_VERSION_DASHED,ou=user,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur \
  -b "ou=group,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur"\
  -w $2
echo ===========================================================3
