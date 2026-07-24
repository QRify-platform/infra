variable "environment" {
  description = "Environment this pool serves (dev or prod)."
  type        = string
}

variable "user_pool_name" {
  type = string
}

variable "domain_prefix" {
  description = "Cognito domain prefix (globally unique per region). Keep stable across rebuilds."
  type        = string
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "google_oauth_secret_id" {
  description = "Secrets Manager secret with GOOGLE_CLIENT_ID + GOOGLE_CLIENT_SECRET for this env."
  type        = string
}

variable "callback_urls" {
  description = "Where Cognito sends the browser after Google OAuth (your app)."
  type        = list(string)
}

variable "logout_urls" {
  description = "Where Cognito sends the browser after logout."
  type        = list(string)
}

variable "secret_prefix" {
  type    = string
  default = "qrify"
}

variable "secret_name" {
  type    = string
  default = "qrify-cognito"
}
