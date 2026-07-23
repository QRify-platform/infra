locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

data "aws_route53_zone" "public" {
  name         = var.domain_name
  private_zone = false
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid     = "AllowExternalDNSServiceAccount"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "QRifyExternalDNSRole"
  description        = "IRSA for ExternalDNS to manage Route53 records for QRify"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "ExternalDNS"
  }
}

# https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/aws/#iam-policy
data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "ChangeRecordsInQRifyZone"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.public.zone_id}",
    ]
  }

  statement {
    sid    = "ListZonesAndRecords"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "QRifyExternalDNSPolicy"
  description = "Route53 access for ExternalDNS (QRify public zone only for changes)"
  policy      = data.aws_iam_policy_document.external_dns.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
