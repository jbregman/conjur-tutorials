echo 'export CONJUR_HOST=\' >> my_conjur_env.sh
cat ~/.conjurrc | grep appliance | cut -d/ -f3 >> my_conjur_env.sh
echo 'export CONJUR_ACCOUNT=\' >> my_conjur_env.sh
cat ~/.conjurrc | grep account| cut -d' ' -f2 >> my_conjur_env.sh
echo 'export CONJUR_POLICY_VERSION=\' >> my_conjur_env.sh
cat policy.json | jsonfield version >> my_conjur_env.sh
echo 'export CONJUR_POLICY_VERSION_DASHED=\' >> my_conjur_env.sh
cat policy.json | jsonfield version | tr '.' '-' >> my_conjur_env.sh
echo 'export CONJUR_COLLECTION=\' >> my_conjur_env.sh
cat policy.json | jsonfield collection >> my_conjur_env.sh



chmod a+x my_conjur_env.sh

#now add the information from the environment
. ./my_conjur_env.sh

export CONJUR_LDAP_POLICY=$CONJUR_COLLECTION/ldap-$CONJUR_POLICY_VERSION
export TOMCAT_HOST=$CONJUR_LDAP_POLICY/tomcat

#update the file with the tomcat host

echo 'export TOMCAT_HOST=\' >> my_conjur_env.sh
echo $TOMCAT_HOST >> my_conjur_env.sh

echo "Creating the host..."

conjur host create $CONJUR_LDAP_POLICY/tomcat | tee tomcat.json

echo "Creating objects...."
conjur policy load --as-group security_admin --collection $CONJUR_COLLECTION --context ldap.json ldap.rb 

echo Dashed Version=$CONJUR_POLICY_VERSION_DASHED

echo 'export HOST_API_KEY=\' >> my_keys.sh
cat tomcat.json | jsonfield api_key >> my_keys.sh
echo 'export KEVIN_API_KEY=\' >> my_keys.sh
cat ldap.json | jsonfield api_keys.$CONJUR_ACCOUNT:user:kevin@$CONJUR_COLLECTION-ldap-$CONJUR_POLICY_VERSION_DASHED >> my_keys.sh
echo 'export KEVIN_USERNAME=\' >> my_keys.sh
echo kevin@$CONJUR_COLLECTION-ldap-$CONJUR_POLICY_VERSION_DASHED >> my_keys.sh

chmod a+x my_keys.sh

. ./my_keys.sh

echo "Testing LDAP Connection...."

./ldap-test.sh $HOST_API_KEY $KEVIN_API_KEY | tee ldap_test_results

echo "Conjurizing hots...."

cat tomcat.json | conjurize > conjurize.sh


