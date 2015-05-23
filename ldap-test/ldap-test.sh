. ./my_conjur_env.sh
. ./my_keys.sh

echo Conjur Host: $CONJUR_HOST
echo Tomcat host: $TOMCAT_HOST
echo Account:  $CONJUR_ACCOUNT



ldapsearch -H ldaps://$CONJUR_HOST \
  -D uid=$TOMCAT_HOST,ou=host,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur \
  -w $HOST_API_KEY \
  -b "ou=user,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur"

echo ===========================================1
ldapsearch -H ldaps://$CONJUR_HOST \
  -D uid=$TOMCAT_HOST,ou=host,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur \
  -w $HOST_API_KEY \
  -b "ou=group,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur"
echo ===========================================================2
ldapsearch -H ldaps://$CONJUR_HOST \
  -D uid=kevin@$CONJUR_COLLECTION-ldap-$CONJUR_POLICY_VERSION_DASHED,ou=user,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur \
  -b "ou=group,host=$TOMCAT_HOST,account=$CONJUR_ACCOUNT,o=conjur"\
  -w $KEVIN_API_KEY
echo ===========================================================3
