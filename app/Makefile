# workspace select || new could be improved in the future:
# https://github.com/hashicorp/terraform/issues/16191
apply:
	terraform init -reconfigure -input=false -backend-config="bucket=${TERRAFORM_STATE_BUCKET_NAME}" -backend-config="dynamodb_table=${TERRAFORM_STATE_TABLE_NAME}" -backend-config="region=${TERRAFORM_STATE_REGION}"
	terraform workspace select ${DEPLOY_ENV} || terraform workspace new ${DEPLOY_ENV}
	terraform get -update=true
	terraform apply -auto-approve -var-file="${DEPLOY_ENV}.tfvars"
