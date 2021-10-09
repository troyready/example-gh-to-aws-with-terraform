## Overview

This project maintains the configuration for GitHub and application deployment pipelines.

### One-Time Setup

Create the Terraform state resources via CloudFormation and populate the backend config file:

```bash
aws cloudformation create-stack --stack-name shared-tf-state --region us-west-2 --template-body file://deps/tf-state.yml
aws cloudformation wait stack-create-complete --region us-west-2 --stack-name shared-tf-state
echo "bucket         = \"$(aws cloudformation describe-stacks --region us-west-2 --stack-name shared-tf-state --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" --output text)\"" >> backend-prod.tfvars
echo "dynamodb_table = \"$(aws cloudformation describe-stacks --region us-west-2 --stack-name shared-tf-state --query "Stacks[0].Outputs[?OutputKey=='TableName'].OutputValue" --output text)\"" >> backend-prod.tfvars
echo "region         = \"us-west-2\"" > backend-prod.tfvars
```

or PowerShell:

```powershell
aws cloudformation create-stack --stack-name shared-tf-state --region us-west-2 --template-body file://deps/tf-state.yml
aws cloudformation wait stack-create-complete --region us-west-2 --stack-name shared-tf-state
"bucket         = `"$(aws cloudformation describe-stacks --region us-west-2 --stack-name shared-tf-state --query `"Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue`" --output text)`"" | Out-File -Encoding utf8 -FilePath .\backend-prod.tfvars
"dynamodb_table = `"$(aws cloudformation describe-stacks --region us-west-2 --stack-name shared-tf-state --query `"Stacks[0].Outputs[?OutputKey=='TableName'].OutputValue`" --output text)`"" | Out-File -Encoding utf8 -Append -FilePath .\backend-prod.tfvars
"region         = `"us-west-2`"" | Out-File -Encoding utf8 -Append -FilePath .\backend-prod.tfvars
```
