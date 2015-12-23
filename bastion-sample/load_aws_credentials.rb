#!/usr/bin/env ruby

require 'csv'
require 'conjur/cli'

Conjur::Config.load
Conjur::Config.apply

conjur = Conjur::Authn.connect nil, noask: true

print 'Loading AWS credentials from '
puts ARGV[0]

row_count=0

CSV.foreach(ARGV[0]) do |row|
   row_count=row_count+1

   #This is the row in the credentials file
   #That has the the username, api_key, api_secret
   if row_count==2
	user = row[0]

aws_key = conjur.create_variable 'text/plain', 'aws_key', id: user+'/aws_key', value: row[1] 

aws_secret = conjur.create_variable 'text/plain', 'aws_secret', id: user+'/aws_secret', value: row[2] 

   end
end

