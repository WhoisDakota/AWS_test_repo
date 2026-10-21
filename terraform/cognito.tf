resource "aws_cognito_user_pool" "main" {
  name                     = "${var.project}-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length = 12
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project}-${random_id.suffix.hex}"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_pool_client" "web" {
  name            = "${var.project}-web"
  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false # browser app: PKCE instead of a client secret

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors        = "ENABLED"

  callback_urls = ["https://${aws_cloudfront_distribution.site.domain_name}/", "http://localhost:3000/"]
  logout_urls   = ["https://${aws_cloudfront_distribution.site.domain_name}/", "http://localhost:3000/"]
}