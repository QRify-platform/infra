
terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "qrify-tf-state"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "qrify-tf-locks"
    encrypt        = true
  }
}
