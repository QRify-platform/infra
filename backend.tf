terraform {
  backend "s3" {
    bucket       = "qrify-terraform-state"
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}