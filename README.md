# conjur-tutorials

## Starting the Vagrant box
Before you start the Vagrant box, you need to set the following values in your environment.  

Example setup.sh
=
export CONJUR_HOST=<hostname of your conjur server>
export CONJUR_PASSWORD=<admin password for the conjur server>

You can source the shell

. ./setup.sh

and then start the virtual machine

vagrant up



