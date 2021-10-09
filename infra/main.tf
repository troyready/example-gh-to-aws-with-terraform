terraform {
  backend "s3" {
    key    = "infra.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
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

# https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token
provider "github" {}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
