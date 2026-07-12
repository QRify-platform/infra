locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowEKSServiceAccounts"
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
      test     = "StringLike"
      variable = "${local.oidc_host}:sub"
      values = [
        for ns in var.namespaces :
        "system:serviceaccount:${ns}:${var.service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "api" {
  name               = "QRifyWebApiS3Role"
  description        = "IRSA role for qrify-web-api to access the QR storage bucket"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "WebApiIRSA"
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}"
    ]
  }

  statement {
    sid    = "ObjectReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name        = "QRifyWebApiS3Policy"
  description = "S3 access for qrify-web-api"
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.api.name
  policy_arn = aws_iam_policy.s3.arn
}
