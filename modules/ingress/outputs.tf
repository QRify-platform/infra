output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.apex.certificate_arn
}

output "apex_domain_name" {
  value = var.domain_name
}

output "dev_hostname" {
  value = var.dev_hostname
}

output "api_hostname" {
  value = var.api_hostname
}

output "api_dev_hostname" {
  value = var.api_dev_hostname
}

output "portal_hostname" {
  value = var.portal_hostname
}
