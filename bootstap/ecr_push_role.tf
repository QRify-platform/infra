data "aws_iam_policy_document" "ecr_push_role_trust" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
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
        for repo in var.ecr_push_github_repositories :
        "repo:${var.github_organization}/${repo}:*"
      ]
    }
  }
}

resource "aws_iam_role" "ecr_push" {
  name                 = "QRifyECRPushRole"
  description          = "Role used by GitHub Actions to build and push images to ECR"
  assume_role_policy   = data.aws_iam_policy_document.ecr_push_role_trust.json
  max_session_duration = 3600

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "ECRPushCI"
  }
}

data "aws_iam_policy_document" "ecr_push_permissions" {
  statement {
    sid    = "ECRAuthToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPullQRifyRepos"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/qrify-*"
    ]
  }
}

resource "aws_iam_policy" "ecr_push" {
  name        = "QRifyECRPushPolicy"
  description = "Permissions required to push images to QRify ECR repositories"
  policy      = data.aws_iam_policy_document.ecr_push_permissions.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.ecr_push.name
  policy_arn = aws_iam_policy.ecr_push.arn
}

output "ecr_push_role_arn" {
  description = "ARN of the role assumed by GitHub Actions for ECR push"
  value       = aws_iam_role.ecr_push.arn
}
