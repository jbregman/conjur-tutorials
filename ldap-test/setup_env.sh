echo 'export HOST_API_KEY=\' >> myenv.sh
cat tomcatserver.json | jsonfield api_key >> myenv.sh
echo 'export KEVIN_API_KEY=\' >> myenv.sh
cat ldap.json | jsonfield api_keys.joshops:user:kevin@development-ldap-1-0 >> myenv.sh
chmod a+x myenv.sh
