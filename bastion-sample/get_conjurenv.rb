role="#{ENV['ROLE']}"
collection="#{ENV['COLLECTION']}"
account="#{ENV['CONJUR_ACCOUNT']}"
user="#{ENV['CONJUR_USER']}"

# Search for all of the variables that the user has access to 

vars = api.resources(kind: "variable");

env_file = open(".conjurenv","w")

#if there is a user then do the user first
valid_owner = account+":user:"+user
vars.each do |var|
    
    
    summon_type = var.annotations["summon:type"]
    summon_name = var.annotations["summon:name"]
    if (summon_type != nil && summon_name !=nil)
        
        if (var.owner == valid_owner)
            puts "wriring summon data to .conjurenv "+var.resource_id+" "+var.owner
            env_file.write(summon_name+": "+summon_type+" "+var.resource_id.split(":")[2]+"\n")
        end
    end
end

#then add the role
if (role != nil && role != "") 
    valid_owner = account+":policy:"+collection+"/aws/role/"+role    


    vars.each do |var|
    
    
        summon_type = var.annotations["summon:type"]
        summon_name = var.annotations["summon:name"]
        if (summon_type != nil && summon_name !=nil)
        
            if (var.owner == valid_owner)
                puts "wriring summon data to .conjurenv "+var.resource_id+" "+var.owner
                env_file.write(summon_name+": "+summon_type+" "+var.resource_id.split(":")[2]+"\n")
            end
        end
    end
end


env_file.close

puts "Done"
        
        
