data "aws_iam_policy_document" "eks_access_role_trust" {
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

      values = [
        for repo in var.eks_access_github_repositories :
        "repo:${var.github_organization}/${repo}:*"
      ]
    }
  }
}

resource "aws_iam_role" "eks_access" {
  name                 = "QRifyEKSAccessRole"
  description          = "Role used by GitHub Actions to access the QRify EKS cluster (kubectl / Argo CD sync)"
  assume_role_policy   = data.aws_iam_policy_document.eks_access_role_trust.json
  max_session_duration = 3600

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "EKSAccessCI"
  }
}

data "aws_iam_policy_document" "eks_access_permissions" {
  statement {
    sid    = "EKSDescribeForKubeconfig"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_access" {
  name        = "QRifyEKSAccessPolicy"
  description = "Minimal IAM permissions for GitHub Actions to generate an EKS kubeconfig"
  policy      = data.aws_iam_policy_document.eks_access_permissions.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.eks_access.name
  policy_arn = aws_iam_policy.eks_access.arn
}
