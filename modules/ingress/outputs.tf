output "nginx_ingress_service_hostname" {
  value = try(data.kubernetes_service.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "nginx_ingress_service_ip" {
  value = try(data.kubernetes_service.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].ip, "pending")
}
