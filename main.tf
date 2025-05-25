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

module "qrify_iam" {
  source = "./iam"
  s3_bucket_arn = module.qrify_s3.bucket_arn
}