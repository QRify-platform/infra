# Cognito User Pool — QRify identity (email/password + Google via Hosted UI).
#
# Google OAuth client ID/secret come from Secrets Manager
# (secrets-manager repo → qrify/platform/google-auth), not GitHub Actions secrets.
#
# Pieces:
#   1) user pool     — the user directory
#   2) app client    — permission slip for qrify-web (public + PKCE)
#   3) domain        — stable Hosted UI URL (also Google's redirect target)
#   4) Google IdP    — "Sign in with Google"
#   5) SM secret     — pool/client/domain for apps (same pattern as DATABASE_URL)

data "aws_secretsmanager_secret_version" "google_oauth" {
  secret_id = var.google_oauth_secret_id
}

locals {
  google_oauth   = jsondecode(data.aws_secretsmanager_secret_version.google_oauth.secret_string)
  cognito_domain = "${var.domain_prefix}.auth.${var.aws_region}.amazoncognito.com"
  cognito_issuer = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.this.id}"

  # Non-secret config apps need to start Hosted UI / verify JWTs.
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
    Name      = var.user_pool_name
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

# Public browser client: no client secret in the frontend; OAuth code + PKCE.
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

  # Google IdP must exist before the client can list it as a provider.
  depends_on = [aws_cognito_identity_provider.google]
}

# Fixed prefix so Google redirect URI stays stable across destroy/rebuild.
# Full Hosted UI host: https://{domain}.auth.{region}.amazoncognito.com
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

# Same path style as RDS: qrify/<env>/qrify-cognito
resource "aws_secretsmanager_secret" "cognito" {
  for_each = toset(var.environments)

  name        = "${var.secret_prefix}/${each.key}/${var.secret_name}"
  description = "QRify ${each.key} Cognito config for web/api"

  tags = {
    Project     = "QRify"
    ManagedBy   = "Terraform"
    Environment = each.key
    SecretName  = var.secret_name
  }
}

resource "aws_secretsmanager_secret_version" "cognito" {
  for_each = toset(var.environments)

  secret_id     = aws_secretsmanager_secret.cognito[each.key].id
  secret_string = jsonencode(local.cognito_config)
}
