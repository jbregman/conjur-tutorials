policy "aws/role/#{ENV['AWS_ROLE']}" do

     policy_resource.annotations['description'] = "A policy for the AWS temporary credentials for AWS IAM role #{ENV['AWS_ROLE']}"

     policy_resource.annotations['arn'] = "#{ENV['ROLE_ARN']}"
     policy_resource.annotations['aws policy'] = "#{ENV['AWS_POLICY']}"



     access_key_id = variable "AccessKeyId"
     access_key_id.resource.annotations['description'] = "AWS Access Key for this role"

     secret_access_key = variable "SecretAccessKey"
     secret_access_key.resource.annotations['description'] = "Secret Access Key for this role"
     session_token = variable "SessionToken"
     session_token.resource.annotations['description'] = "Session Token for this role"


     group "readers" do |group|
	can 'read',access_key_id
        can 'execute',access_key_id
	can 'read',secret_access_key
        can 'execute',secret_access_key
	can 'read',session_token
        can 'execute',session_token
     end

     group "updaters" do |group|
	can 'read',access_key_id
        can 'update',access_key_id
	can 'read',secret_access_key
        can 'update',secret_access_key
	can 'read',session_token
        can 'update',session_token
     end

end
