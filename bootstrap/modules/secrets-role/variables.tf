variable "github_oidc_provider_arn" {
  type = string
}

variable "github_organization" {
  type = string
}

variable "github_organization_id" {
  type = string
}

variable "github_repository" {
  description = "GitHub repo allowed to assume this role (secrets-manager)."
  type        = string
  default     = "secrets-manager"
}

variable "aws_region" {
  type = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used by SOPS."
  type        = string
}

variable "terraform_state_bucket_name" {
  type = string
}
