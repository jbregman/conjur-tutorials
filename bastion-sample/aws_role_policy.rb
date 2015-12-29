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


end
