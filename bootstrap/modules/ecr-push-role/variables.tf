variable "github_oidc_provider_arn" {
  type = string
}

variable "github_organization" {
  type = string
}

variable "ecr_push_github_repositories" {
  type = list(string)
}

variable "aws_region" {
  type = string
}
