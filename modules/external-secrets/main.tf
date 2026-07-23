locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eso_assume" {
  statement {
    sid     = "AllowESOServiceAccount"
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

resource "aws_iam_role" "eso" {
  name               = "QRifyExternalSecretsRole"
  description        = "IRSA for External Secrets Operator to read QRify Secrets Manager secrets"
  assume_role_policy = data.aws_iam_policy_document.eso_assume.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "ExternalSecrets"
  }
}

data "aws_iam_policy_document" "eso" {
  statement {
    sid    = "ReadQRifySecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:qrify/*"
    ]
  }

  statement {
    sid    = "ListSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:ListSecrets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "eso" {
  name        = "QRifyExternalSecretsPolicy"
  description = "Read qrify/* secrets from Secrets Manager"
  policy      = data.aws_iam_policy_document.eso.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}
