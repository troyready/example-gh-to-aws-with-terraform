terraform init -reconfigure -backend-config="backend-prod.tfvars"

# workspace select || new could be improved in the future:
# https://github.com/hashicorp/terraform/issues/16191
terraform workspace select prod
if(-Not ($?)) {
   terraform workspace new prod
}

terraform get -update=true
terraform apply -auto-approve -var-file="prod.tfvars"
