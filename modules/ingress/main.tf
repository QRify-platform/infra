data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_acm_certificate" "apex" {
  domain_name               = var.domain_name
  subject_alternative_names = [
    var.dev_hostname,
    var.portal_hostname,
    var.portal_dev_hostname,
  ]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "IngressTLS"
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.apex.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "apex" {
  certificate_arn         = aws_acm_certificate.apex.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress-controller"
  namespace        = var.namespace
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_chart_version
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode({
      controller = {
        publishService = {
          enabled = true
        }
        service = {
          type = "LoadBalancer"
          # ACM terminates TLS on the ELB; nginx must receive plain HTTP on both 80 and 443.
          targetPorts = {
            http  = "http"
            https = "http"
          }
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = aws_acm_certificate_validation.apex.certificate_arn
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "https"
            "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "60"
          }
        }
      }
    })
  ]

  depends_on = [aws_acm_certificate_validation.apex]
}

resource "null_resource" "wait_for_nginx_ingress_lb" {
  triggers = {
    release  = helm_release.nginx_ingress.id
    wait_gen = "2"
  }

  provisioner "local-exec" {
    command     = <<EOT
      echo "Starting check for NGINX Ingress LoadBalancer..."
      for i in {1..60}; do
        OUTPUT=$(kubectl get svc -n ${var.namespace} nginx-ingress-controller-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>&1)
        echo "Attempt $i: $OUTPUT"
        if [[ ! -z "$OUTPUT" && "$OUTPUT" != *"error"* && "$OUTPUT" != *"NotFound"* ]]; then
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

data "kubernetes_service_v1" "nginx_ingress_lb" {
  metadata {
    name      = "nginx-ingress-controller-ingress-nginx-controller"
    namespace = var.namespace
  }

  depends_on = [null_resource.wait_for_nginx_ingress_lb]
}

resource "terraform_data" "ingress_lb_hostname" {
  input = try(
    data.kubernetes_service_v1.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].hostname,
    ""
  )

  depends_on = [null_resource.wait_for_nginx_ingress_lb]

  lifecycle {
    ignore_changes = [input]
  }
}

locals {
  nginx_lb_hostname = coalesce(
    try(nullif(terraform_data.ingress_lb_hostname.output, ""), null),
    try(
      data.kubernetes_service_v1.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].hostname,
      null
    )
  )
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = local.nginx_lb_hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [terraform_data.ingress_lb_hostname]
}

resource "aws_route53_record" "dev" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.dev_hostname
  type    = "A"

  alias {
    name                   = local.nginx_lb_hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [terraform_data.ingress_lb_hostname]
}

resource "aws_route53_record" "portal" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.portal_hostname
  type    = "A"

  alias {
    name                   = local.nginx_lb_hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [terraform_data.ingress_lb_hostname]
}

resource "aws_route53_record" "portal_dev" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.portal_dev_hostname
  type    = "A"

  alias {
    name                   = local.nginx_lb_hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [terraform_data.ingress_lb_hostname]
}
