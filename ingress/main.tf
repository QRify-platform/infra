resource "null_resource" "wait_for_nginx_ingress_lb" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Starting check for NGINX Ingress LoadBalancer..."
      for i in {1..60}; do
        OUTPUT=$(kubectl get svc -n ${var.namespace} nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>&1)
        echo "Attempt $i: $OUTPUT"
        if [[ ! -z "$OUTPUT" && "$OUTPUT" != *"error"* ]]; then
          echo "Ingress LB ready: $OUTPUT"
          exit 0
        fi
        echo "Waiting for nginx ingress load balancer..."
        sleep 10
      done
      echo "Timed out waiting for load balancer"
      exit 1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [helm_release.nginx_ingress]
}



resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0" # or latest stable

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}





data "aws_route53_zone" "main" {
  name         = "qrify-web.com"
  private_zone = false
}




data "kubernetes_service" "nginx_ingress_lb" {
  metadata {
    name      = "nginx-ingress-controller-ingress-nginx-controller"
    namespace = "kube-system" 
  }
}


resource "aws_route53_record" "nginx_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "qrify-web.com"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = "Z3AADJGX6KTTL2" # ALB zone ID for us-east-2
    evaluate_target_health = true
  }
}


