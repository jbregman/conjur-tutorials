policy "ldap-#{ENV['CONJUR_POLICY_VERSION']}" do

     host = host "tomcat"

     josh = user "josh"
     kevin = user "kevin"

     devs = group "devs" do
          add_member josh
          add_member host
     end
     ops  = group "ops" do
          add_member kevin
          add_member host
     end


     devs.can "execute",host

     ops.can "execute",host
end
