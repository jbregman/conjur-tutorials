#!/bin/bash
eval $(ssh-agent)
ssh-add $PUBLIC_SUBNET_SSH_KEY
#ssh $1
ssh $1 $2 $3 $4 $5
