module "state_bucket" {
  source      = "./modules/state-bucket"
  bucket_name = var.terraform_state_bucket_name
}

module "github_oidc" {
  source = "./modules/github-oidc"
}

module "terraform_role" {
  source = "./modules/terraform-role"

  github_oidc_provider_arn = module.github_oidc.arn
  github_organization      = var.github_organization
  github_repository        = var.github_repository
  aws_region               = var.aws_region
}

module "ecr_push_role" {
  source = "./modules/ecr-push-role"

  github_oidc_provider_arn = module.github_oidc.arn
  github_organization      = var.github_organization
  github_organization_id   = var.github_organization_id
  aws_region               = var.aws_region
}

module "eks_access_role" {
  source = "./modules/eks-access-role"

  github_oidc_provider_arn       = module.github_oidc.arn
  github_organization            = var.github_organization
  eks_access_github_repositories = var.eks_access_github_repositories
}

module "dns" {
  source      = "./modules/dns"
  domain_name = var.domain_name
}

module "secrets_kms" {
  source = "./modules/secrets-kms"
}

module "secrets_role" {
  source = "./modules/secrets-role"

  github_oidc_provider_arn    = module.github_oidc.arn
  github_organization         = var.github_organization
  github_organization_id      = var.github_organization_id
  github_repository           = var.secrets_github_repository
  aws_region                  = var.aws_region
  kms_key_arn                 = module.secrets_kms.key_arn
  terraform_state_bucket_name = var.terraform_state_bucket_name
}
