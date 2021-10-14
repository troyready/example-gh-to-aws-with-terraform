# Continuous Deployment to AWS Using GitHub Actions and Terraform

## Overview

This is a brief how-to on setting up a GitHub repo to deploy to AWS. Notable features include:

* Every element is configured entirely in code.
* No static credentials are used for AWS access (via [GitHub Actions OIDC support](https://github.com/github/roadmap/issues/249))
* Permissions granted to the AWS deployment role are limited to only the [least amount required](https://en.wikipedia.org/wiki/Principle_of_least_privilege)

## Prereqs

* [AWS CLI](https://aws.amazon.com/cli/)
  * Ensure you are logged in (i.e. `aws sts get-caller-identity` should show you information about your current credentials)
* [GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) set as the `GITHUB_TOKEN` environment variable
  * Alternatively, any [supported authentication method for the Terraform GitHub provider](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication) can be used; just update the provider config in infra/main.tf
* [Terraform](https://www.terraform.io/) in PATH (or [tfenv](https://github.com/tfutils/tfenv) installed)
* [git](https://git-scm.com/) installed and configured with access to your GitHub account
  * User config need to be in place, i.e. `git config --global user.email "you@example.com"` & `git config --global user.name "Your Name"`

With the necessary software/authentication in place, download a copy of this project:

* Click the green `Code` button in the upper right then `Download ZIP`
* Extract the directory in the downloaded zip file; it in turn contains the 2 directories with which we'll be working

## Walkthrough

### Structure

This project contains two directories, each representing a repo:

1. An example application repo ("app") that, on every commit to its `main` branch, deploys to AWS.
2. A shared infrastructure repo ("infra") which contains the code creating the app repo and supporting components

### Infra Repo Setup

First, open your terminal in the infra repo and perform the "One-Time Setup" commands in its README. This will generated a file named `backend-prod.tfvars` with contents like the following:

```
bucket         = "shared-tf-state-terraformstatebucket-abc123abc123a"
dynamodb_table = "shared-tf-state-TerraformStateTable-abc123abc123a"
region         = "us-west-2"
```

With the backend setup complete, deploy the repo & AWS components:

```bash
make apply_prod
```

or in PowerShell:
```powershell
.\make_apply_prod.ps1

# May require running this first:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

You will now have an empty private repo named `app` in your GitHub Account and an IAM Role in your AWS account that it will use for deployments.

### App Repo

Now that the GitHub repo has been created, commiting to it's `main` branch will trigger deployments (in the case of thie example, it will create a Systems Manager Parameter named `/app/prod/example`).

Starting in the `infra` directory, retrieve the new repo's SSH address and commit/push its contents:

```bash
$APP_REPO_REPO_SSH_URI=$(terraform output -raw app_repo_ssh_clone_url)
cd ../app
git init
git add .github .gitignore .terraform-version .terraform.lock.hcl *
git commit -m "initial commit"
git branch -M main
git remote add origin $APP_REPO_REPO_SSH_URI
git push -u origin main
```

or in PowerShell:
```powershell
$APP_REPO_REPO_SSH_URI = terraform output -raw app_repo_ssh_clone_url
cd ../app
git init
git add .github .gitignore .terraform-version .terraform.lock.hcl *
git commit -m "initial commit"
git branch -M main
git remote add origin $APP_REPO_REPO_SSH_URI
git push -u origin main
```

Note: The push requires an SSH key associated with your GitHub account. To use HTTP credentials instead, substitute `app_repo_http_clone_url` for `app_repo_ssh_clone_url`.

With the commit pushed to the repo, GitHub Actions will run Terraform and create the SSM parameter. Future changes can be made by modifying the Terraform files, commiting them to the repo, and pushing them to GitHub.

## Acknowledgements

OIDC connect support in GitHub Actions was initially detailed in this [excellent blog post by Aidan Steele](https://awsteele.com/blog/2021/09/15/aws-federation-comes-to-github-actions.html).
