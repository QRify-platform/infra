data "aws_caller_identity" "current" {}

resource "aws_kms_key" "secrets" {
  description             = "SOPS encryption key for QRify secrets-as-code (Secrets Manager repo)"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "SecretsSOPS"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/qrify-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# Allow root + the secrets CI role to use the key. Role ARN is passed in after
# secrets-role is created (or use a two-pass); we grant via key policy update
# from the secrets-role module attachment pattern instead — see key policy below
# for account root so IAM policies on roles can grant kms:*.

data "aws_iam_policy_document" "secrets_key" {
  statement {
    sid    = "EnableRootAccountAdmin"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "secrets" {
  key_id = aws_kms_key.secrets.id
  policy = data.aws_iam_policy_document.secrets_key.json
}
