## Continous Deployment to AWS

The Terraform configuration in this repo is applied on each push to `main` on GitHub.

The GitHub Actions configuration uses [its OIDC support](https://github.com/github/roadmap/issues/249) to do the deployments without static credentials.
