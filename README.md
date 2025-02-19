# tf-aws-infra
Creating terraform for each availbility zone;
while creating, it should destroy existing vpc, for this i have implemented different vpc region

## command to run 
# First run init
### terraform init
# Format tf file
### terraform fmt -check - recursive
# create terraform workspace
### terraform workspace new <workspace_name>
# Apply your tfvars
### terraform apply -var-file="<your_tfvars>.tfvars"
# after the work is done, destroy the vpc
### terraform workspace select <workspace_name>
### terraform destroy -var-file="<your_tfvars>.tfvars"

##### Follow this steps recursively.
