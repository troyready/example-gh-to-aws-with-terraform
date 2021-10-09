resource "github_repository" "app" {
  description = "Example repo deploying to AWS"
  name        = "app"
  visibility  = "private"
}

output "app_repo_http_clone_url" {
  value = github_repository.app.http_clone_url
}
output "app_repo_ssh_clone_url" {
  value = github_repository.app.ssh_clone_url
}

resource "aws_s3_bucket" "app_tf_state" {
  acl           = "private"
  bucket_prefix = "app-tf-state-"
  force_destroy = true
  tags          = var.tags

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "app_tf_state" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  name         = "app-tf-state"
  tags         = var.tags

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_iam_policy_document" "app_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${github_repository.app.full_name}:*",
      ]
    }

    principals {
      type = "Federated"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "app" {
  # App related IAM permissions here
  statement {
    actions = [
      "ssm:DescribeParameters",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:*:${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListTagsForResource",
      "ssm:PutParameter",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/app/*",
    ]
  }

  # Terraform state-related permissions from here
  # https://www.terraform.io/docs/backends/types/s3.html#s3-bucket-permissions
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.app_tf_state.arn,
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.app_tf_state.arn}/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]

    resources = [
      aws_dynamodb_table.app_tf_state.arn,
    ]
  }
}

resource "aws_iam_role" "app" {
  assume_role_policy = data.aws_iam_policy_document.app_assume_role_policy.json
  name_prefix        = "app-github-"
  tags               = var.tags

  inline_policy {
    name   = "Terraform"
    policy = data.aws_iam_policy_document.app.json
  }
}

resource "github_actions_secret" "app_AWS_ROLE_ARN" {
  repository      = github_repository.app.name
  plaintext_value = aws_iam_role.app.arn
  secret_name     = "AWS_ROLE_ARN"
}

resource "github_actions_secret" "app_TERRAFORM_STATE_BUCKET_NAME" {
  repository      = github_repository.app.name
  plaintext_value = aws_s3_bucket.app_tf_state.id
  secret_name     = "TERRAFORM_STATE_BUCKET_NAME"
}

resource "github_actions_secret" "app_TERRAFORM_STATE_REGION" {
  repository      = github_repository.app.name
  plaintext_value = data.aws_region.current.name
  secret_name     = "TERRAFORM_STATE_REGION"
}

resource "github_actions_secret" "app_TERRAFORM_STATE_TABLE_NAME" {
  repository      = github_repository.app.name
  plaintext_value = aws_dynamodb_table.app_tf_state.id
  secret_name     = "TERRAFORM_STATE_TABLE_NAME"
}
