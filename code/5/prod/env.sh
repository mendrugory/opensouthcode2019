# AWS
export TF_VAR_db_instance_class="db.t2.micro"
export TF_VAR_ec2_instance_class="t2.micro"

## APPSERVERS
export TF_VAR_number_of_appserver="2"

# DATABASE
export TF_VAR_database_name="notejam"
export TF_VAR_database_username="username"
export TF_VAR_database_password="password"
export TF_VAR_allocated_storage="5"
