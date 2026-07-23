data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "apex" {
  domain_name = var.domain_name
  subject_alternative_names = [
    var.dev_hostname,
    var.portal_hostname,
    var.portal_dev_hostname,
  ]
  validation_method = "DNS"

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

# App hostnames (qrify-web.com, dev.*, portal.*) are managed by ExternalDNS
# from Ingress resources — not Terraform Route53 aliases.
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
