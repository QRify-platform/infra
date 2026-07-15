variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub Actions OIDC provider."
}

variable "github_organization" {
  type = string
}

variable "github_repository" {
  type = string
}

variable "aws_region" {
  type = string
}
