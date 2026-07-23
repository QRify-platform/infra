data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "secrets_role_trust" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        var.github_oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      # Classic: repo:ORG/REPO:ref:...
      # Immutable (new repos): repo:ORG@ORG_ID/REPO@REPO_ID:ref:...
      values = [
        "repo:${var.github_organization}/${var.github_repository}:*",
        "repo:${var.github_organization}@${var.github_organization_id}/${var.github_repository}@*:*",
      ]
    }
  }
}

resource "aws_iam_role" "secrets" {
  name                 = "QRifySecretsRole"
  description          = "Role used by GitHub Actions / local Terraform in the secrets-manager repo"
  assume_role_policy   = data.aws_iam_policy_document.secrets_role_trust.json
  max_session_duration = 3600

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "SecretsManagerCI"
  }
}

data "aws_iam_policy_document" "secrets_permissions" {
  statement {
    sid    = "SecretsManagerCRUD"
    effect = "Allow"

    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecrets",
      "secretsmanager:PutResourcePolicy",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DeleteResourcePolicy",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
      "secretsmanager:UpdateSecret",
      "secretsmanager:UpdateSecretVersionStage",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:qrify/*"
    ]
  }

  statement {
    sid    = "SecretsManagerList"
    effect = "Allow"

    actions = [
      "secretsmanager:ListSecrets"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KMSForSOPS"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
    ]

    resources = [var.kms_key_arn]
  }

  statement {
    sid    = "TerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket_name}",
      "arn:aws:s3:::${var.terraform_state_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "secrets" {
  name        = "QRifySecretsPolicy"
  description = "Secrets Manager + KMS + state for the secrets-manager repo"
  policy      = data.aws_iam_policy_document.secrets_permissions.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.secrets.name
  policy_arn = aws_iam_policy.secrets.arn
}
