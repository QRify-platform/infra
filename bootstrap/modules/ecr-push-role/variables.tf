variable "github_oidc_provider_arn" {
  type = string
}

variable "github_organization" {
  type = string
}

variable "github_organization_id" {
  description = "Numeric GitHub org id used in OIDC sub claims (repo:ORG@ID/...)."
  type        = string
}

variable "aws_region" {
  type = string
}
