output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.web.id
}

output "domain" {
  value = local.cognito_domain
}

output "issuer" {
  value = local.cognito_issuer
}

output "hosted_ui_login_url" {
  description = "Base Hosted UI login URL (add client_id, redirect_uri, etc. from the web app)."
  value       = "https://${local.cognito_domain}/login"
}

output "google_redirect_uri" {
  description = "Put this exact URI in Google Cloud OAuth client Authorized redirect URIs."
  value       = "https://${local.cognito_domain}/oauth2/idpresponse"
}

output "secret_names" {
  value = { for k, s in aws_secretsmanager_secret.cognito : k => s.name }
}
