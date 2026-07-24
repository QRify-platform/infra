# Cognito User Pool — QRify identity (email/password + Google).
#
# One module instance per environment (separate pools, domains, Google secrets).
# Google OAuth: secrets-manager → qrify/<env>/google-auth
# App config → Secrets Manager as qrify/<env>/qrify-cognito

data "aws_secretsmanager_secret_version" "google_oauth" {
  secret_id = var.google_oauth_secret_id
}

locals {
  google_oauth   = jsondecode(data.aws_secretsmanager_secret_version.google_oauth.secret_string)
  cognito_domain = "${var.domain_prefix}.auth.${var.aws_region}.amazoncognito.com"
  cognito_issuer = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.this.id}"

  cognito_config = {
    COGNITO_REGION       = var.aws_region
    COGNITO_USER_POOL_ID = aws_cognito_user_pool.this.id
    COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.web.id
    COGNITO_DOMAIN       = local.cognito_domain
    COGNITO_ISSUER       = local.cognito_issuer
  }
}

resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  tags = {
    Name        = var.user_pool_name
    Project     = "QRify"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

# Public browser client: no client secret; SRP for custom UI + OAuth code+PKCE for Google.
resource "aws_cognito_user_pool_client" "web" {
  name         = "${var.user_pool_name}-web"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO", "Google"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"

  depends_on = [aws_cognito_identity_provider.google]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = local.google_oauth["GOOGLE_CLIENT_ID"]
    client_secret    = local.google_oauth["GOOGLE_CLIENT_SECRET"]
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_secretsmanager_secret" "cognito" {
  name        = "${var.secret_prefix}/${var.environment}/${var.secret_name}"
  description = "QRify ${var.environment} Cognito config for web/api"

  tags = {
    Project     = "QRify"
    ManagedBy   = "Terraform"
    Environment = var.environment
    SecretName  = var.secret_name
  }
}

resource "aws_secretsmanager_secret_version" "cognito" {
  secret_id     = aws_secretsmanager_secret.cognito.id
  secret_string = jsonencode(local.cognito_config)
}
