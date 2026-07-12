


module "qrify_ecr" {
  source = "./modules/ecr"

  repository_names = [
    "qrify-web-dev",
    "qrify-web-prod",
    "qrify-web-api-dev",
    "qrify-web-api-prod"
  ]
}


module "qrify_s3" {
  source = "./modules/s3"
  bucket_name = "qrify-web-platform-storage"
}

module "eks" {
  source = "./modules/eks"
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "argo_rollouts" {
  source = "./modules/argo-rollouts"

  depends_on = [module.eks]

  providers = {
    helm = helm
  }
}

module "nginx_ingress" {
  source                = "./modules/ingress"
  namespace             = "kube-system"
  ingress_chart_version = "4.10.0"
  oidc_provider_arn     = module.eks.oidc_provider_arn
  cluster_name          = module.eks.cluster_name

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "sealed_secrets" {
  source = "./modules/bitnami"
  cluster_name = module.eks.cluster_name

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}