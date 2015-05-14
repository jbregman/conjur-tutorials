# git-setup

1. conjur policy load --as-group security_admin --collection internal -c github.json github.rb

2. cat .ssh/id_rsa | conjur variable values add internal/github-2.0/ssh_key


