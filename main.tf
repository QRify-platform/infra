module "qrify_ecr" {
  source = "./modules/ecr"

  repository_names = [
    "qrify-web-dev",
    "qrify-web-prod",
    "qrify-web-api-dev",
    "qrify-web-api-prod",
    "qrify-portal-dev",
    "qrify-portal-prod",
  ]
}

module "qrify_s3" {
  source = "./modules/s3"

  buckets = {
    dev  = "qrify-web-platform-storage-dev"
    prod = "qrify-web-platform-storage-prod"
  }
}

module "eks" {
  source = "./modules/eks"
}

module "api_irsa" {
  source = "./modules/api-irsa"

  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  s3_bucket_names      = module.qrify_s3.bucket_names
  service_account_name = "qrify-web-api"

  depends_on = [module.eks, module.qrify_s3]
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "nginx_ingress" {
  source = "./modules/ingress"

  depends_on = [module.eks]

  providers = {
    aws  = aws
    helm = helm
  }
}

# IRSA only — operator Helm chart lives in cluster-state/apps-infra/external-secrets
module "external_secrets" {
  source = "./modules/external-secrets"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  aws_region        = "us-east-2"

  depends_on = [module.eks]
}

# IRSA only — ExternalDNS Helm chart lives in cluster-state/apps-infra/external-dns
module "external_dns" {
  source = "./modules/external-dns"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  domain_name       = "qrify-web.com"

  depends_on = [module.eks]
}

# Private Postgres DB
# Credentials → Secrets Manager as qrify/<env>/qrify-web-api-db (ESO → K8s).
module "rds" {
  source = "./modules/rds"

  vpc_id                     = module.eks.vpc_id
  private_subnet_ids         = module.eks.private_subnet_ids
  eks_node_security_group_id = module.eks.cluster_security_group_id

  depends_on = [module.eks]
}

# Cognito user pools (dev / prod).

module "cognito_dev" {
  source = "./modules/cognito"

  environment            = "dev"
  user_pool_name         = "qrify-dev"
  domain_prefix          = "qrify-web-dev"
  google_oauth_secret_id = "qrify/dev/google-auth"

  callback_urls = [
    "http://localhost:3000/auth/callback",
    "https://dev.qrify-web.com/auth/callback",
  ]

  logout_urls = [
    "http://localhost:3000/",
    "https://dev.qrify-web.com/",
  ]
}

module "cognito_prod" {
  source = "./modules/cognito"

  environment            = "prod"
  user_pool_name         = "qrify"
  domain_prefix          = "qrify-web"
  google_oauth_secret_id = "qrify/prod/google-auth"

  callback_urls = [
    "https://qrify-web.com/auth/callback",
  ]

  logout_urls = [
    "https://qrify-web.com/",
  ]
}

