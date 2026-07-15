variable "github_oidc_provider_arn" {
  type = string
}

variable "github_organization" {
  type = string
}

variable "eks_access_github_repositories" {
  type = list(string)
}
