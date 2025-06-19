


module "qrify_ecr" {
  source = "./ecr"

  repository_names = [
    "qrify-web-dev",
    "qrify-web-prod",
    "qrify-web-api-dev",
    "qrify-web-api-prod"
  ]
}


module "qrify_s3" {
  source = "./s3"
  bucket_name = "qrify-platform-storage"
}

module "eks" {
  source = "./eks"
}

module "argocd" {
  source = "./argocd"

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "nginx_ingress" {
  source                = "./ingress"
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
  source = "./bitnami"
  cluster_name = module.eks.cluster_name

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}