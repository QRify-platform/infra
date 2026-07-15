output "nginx_ingress_service_hostname" {
  value = try(data.kubernetes_service_v1.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.apex.certificate_arn
}

output "apex_domain_name" {
  value = var.domain_name
}

output "dev_hostname" {
  value = var.dev_hostname
}
