

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
}

module "ingress" {
  source = "./ingress"

  cluster_name      = module.eks.cluster_name
  region            = "us-east-2"
  vpc_id            = module.eks.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn

  providers = {
    kubernetes = kubernetes
    helm       = helm
    aws        = aws
  }
}

