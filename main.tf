module "qrify_ecr" {
  source = "./ecr"
  repository_names = [
    "qrify-web",
    "qrify-api"
  ]
}
