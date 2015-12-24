#!/usr/bin/env ruby

require 'csv'
require 'conjur/cli'

# Log in as the Conjur user
Conjur::Config.load
Conjur::Config.apply

conjur = Conjur::Authn.connect nil, noask: true


#The credentials file is a CSV
#The good stuff is on the second row
row_count=0

CSV.foreach(ARGV[0]) do |row|
   row_count=row_count+1

   #This is the row in the credentials file
   #That has the the username, api_key, api_secret
   if row_count==2
	user = conjur.current_role.id

	aws_key = conjur.variable user+'/aws/credentials/AccessKeyId'
        if !aws_key.exists?
             aws_key = conjur.create_variable 'text/plain', 'aws:AccessKeyId', id: user+'/aws/credentials/AccessKeyId', value: row[1] 
        else
             aws_key.add_value row[1]
        end
        
	puts 'AWS_ACCESS_KEY_ID: !var '+user+'/aws/credentials/AccessKeyId'

	aws_secret = conjur.variable user+'/aws/credentials/SecretAccessKey'
	if !aws_secret.exists?

             aws_secret = conjur.create_variable 'text/plain', 'aws:SecretAccessKey', id: user+'/aws/credentials/SecretAccessKey', value: row[2] 
	else
	     aws_secret.add_value row[2]
        end

	puts 'AWS_SECRET_ACCESS_KEY: !var '+user+'/aws/credentials/SecretAccessKey'

   end
end

