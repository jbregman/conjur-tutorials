policy "github-#{ENV['CONJUR_POLICY_VERSION']}" do

    github_ssh_key = variable "ssh_key"

    github_users = group "git_users" do


       can "read",github_ssh_key


    end

    

end
