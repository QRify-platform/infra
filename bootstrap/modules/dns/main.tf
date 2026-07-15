resource "aws_route53_zone" "primary" {
  name    = var.domain_name
  comment = "QRify public DNS (long-lived)"

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "PublicDNS"
  }
}
