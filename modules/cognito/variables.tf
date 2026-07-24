variable "user_pool_name" {
  type    = string
  default = "qrify"
}

variable "domain_prefix" {
  description = "Cognito Hosted UI domain prefix (globally unique per region). Keep stable across rebuilds."
  type        = string
  default     = "qrify-web"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "google_oauth_secret_id" {
  description = "Secrets Manager secret id/name with GOOGLE_CLIENT_ID + GOOGLE_CLIENT_SECRET (from secrets-manager repo)."
  type        = string
  default     = "qrify/platform/google-auth"
}

variable "callback_urls" {
  description = "Where Cognito sends the browser after login (your app)."
  type        = list(string)
}

variable "logout_urls" {
  description = "Where Cognito sends the browser after logout."
  type        = list(string)
}

variable "environments" {
  type    = list(string)
  default = ["dev", "prod"]
}

variable "secret_prefix" {
  type    = string
  default = "qrify"
}

variable "secret_name" {
  type    = string
  default = "qrify-cognito"
}
