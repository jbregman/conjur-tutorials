# git-setup

export CONJUR_COLLECTION = "development"
export CONJUR_VERSION = "1.0"

conjur policy load --as-group security_admin --collection $CONJUR_COLLECTION -c github.json github.rb

cat .ssh/id_rsa | conjur variable values add $CONJUR_COLLECTION/github-$CONJUR_VERSION/ssh_key


