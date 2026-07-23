output "role_arn" {
  description = "IRSA role ARN for ExternalDNS (annotate the ServiceAccount)."
  value       = aws_iam_role.external_dns.arn
}

output "role_name" {
  value = aws_iam_role.external_dns.name
}

output "hosted_zone_id" {
  description = "Route53 zone ExternalDNS is allowed to change."
  value       = data.aws_route53_zone.public.zone_id
}

output "namespace" {
  value = var.namespace
}

output "service_account_name" {
  value = var.service_account_name
}
