require 'csv'


#The credentials file is a CSV
#The good stuff is on the second row
row_count=0


csv = CSV($stdin, :row_sep => "\r\n")

puts "Loading..."

csv.each do |row|
   row_count=row_count+1

   #This is the row in the credentials file
   #That has the the username, api_key, api_secret
   if row_count==2
	    user = api.current_role.id

	    aws_key = variable user+'/aws/credentials/AccessKeyId'
        if !aws_key.exists?
            aws_key = api.create_variable 'text/plain', 'aws:AccessKeyId', id: user+'/aws/credentials/AccessKeyId', value: row[1] 
        else
            aws_key.add_value row[1]
        end
        aws_key.resource.annotations['description'] = "AWS Access Key Id for "+row[0]
        aws_key.resource.annotations['summon:name'] = "AWS_ACCESS_KEY_ID"
	    aws_key.resource.annotations['summon:type'] = "!var"
        
	
	    aws_secret = variable user+'/aws/credentials/SecretAccessKey'
	    if !aws_secret.exists?
            aws_secret = api.create_variable 'text/plain', 'aws:SecretAccessKey', id: user+'/aws/credentials/SecretAccessKey', value: row[2] 
	    else
	        aws_secret.add_value row[2]
        end
    
        aws_secret.resource.annotations['description'] = "AWS Secret Access Key for "+row[0]
        aws_secret.resource.annotations['summon:name'] = "AWS_SECRET_ACCESS_KEY"
	    aws_secret.resource.annotations['summon:type'] = "!var"

   end
end

