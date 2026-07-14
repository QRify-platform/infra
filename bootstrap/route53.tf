resource "aws_route53_zone" "primary" {
  name    = var.domain_name
  comment = "QRify public DNS (long-lived)"

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "PublicDNS"
  }
}

output "route53_zone_id" {
  description = "Hosted zone ID for the public QRify domain."
  value       = aws_route53_zone.primary.zone_id
}

output "route53_name_servers" {
  description = "Set these as custom nameservers at the registrar (domains.com)."
  value       = aws_route53_zone.primary.name_servers
}

output "route53_domain_name" {
  description = "Apex domain managed by this hosted zone."
  value       = aws_route53_zone.primary.name
}
