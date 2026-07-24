locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

# One IRSA role per env so the prod API cannot touch the dev bucket (and vice versa).
data "aws_iam_policy_document" "assume_role" {
  for_each = var.s3_bucket_names

  statement {
    sid     = "AllowEKSServiceAccount"
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
      values   = ["system:serviceaccount:${each.key}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "api" {
  for_each = var.s3_bucket_names

  name               = "QRifyWebApiS3Role-${each.key}"
  description        = "IRSA for qrify-web-api in ${each.key} → S3 ${each.value}"
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json

  tags = {
    Project     = "QRify"
    ManagedBy   = "Terraform"
    Purpose     = "WebApiIRSA"
    Environment = each.key
  }
}

data "aws_iam_policy_document" "s3" {
  for_each = var.s3_bucket_names

  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${each.value}"
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
      "arn:aws:s3:::${each.value}/*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  for_each = var.s3_bucket_names

  name        = "QRifyWebApiS3Policy-${each.key}"
  description = "S3 access for qrify-web-api (${each.key})"
  policy      = data.aws_iam_policy_document.s3[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3" {
  for_each = var.s3_bucket_names

  role       = aws_iam_role.api[each.key].name
  policy_arn = aws_iam_policy.s3[each.key].arn
}
