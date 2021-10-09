data "tls_certificate" "github_actions_oidc_provider" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  tags = var.tags
  url  = "https://token.actions.githubusercontent.com"

  client_id_list = sort(distinct([
    for x in [
      github_repository.app.full_name,
    ] : "https://github.com/${split("/", x)[0]}"
  ]))

  thumbprint_list = [
    data.tls_certificate.github_actions_oidc_provider.certificates[0].sha1_fingerprint,
  ]
}
