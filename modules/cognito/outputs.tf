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

output "google_redirect_uri" {
  description = "Put this exact URI in the Google OAuth client Authorized redirect URIs for this env."
  value       = "https://${local.cognito_domain}/oauth2/idpresponse"
}

output "secret_name" {
  value = aws_secretsmanager_secret.cognito.name
}
