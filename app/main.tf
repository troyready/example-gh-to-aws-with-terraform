terraform {
  backend "s3" {
    key    = "app.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {
  type = string
}
variable "tags" {
  default = {}
  type    = map
}

provider "aws" {
  region = var.region
}

resource "aws_ssm_parameter" "app_param_example" {
  name  = "/app/${terraform.workspace}/example"
  tags  = var.tags
  type  = "String"
  value = "example"
}
