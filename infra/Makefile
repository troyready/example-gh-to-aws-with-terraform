# workspace select || new could be improved in the future:
# https://github.com/hashicorp/terraform/issues/16191
apply_prod:
	terraform init -reconfigure -backend-config="backend-prod.tfvars"
	terraform workspace select prod || terraform workspace new prod
	terraform get -update=true
	terraform apply -var-file="prod.tfvars"
