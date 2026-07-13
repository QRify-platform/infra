data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_role_trust" {
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
        "repo:${var.github_organization}/${var.github_repository}:*"
      ]
    }
  }
}

resource "aws_iam_role" "terraform" {
  name                 = "QRifyTerraformRole"
  description          = "Role used by GitHub Actions to provision QRify infrastructure"
  assume_role_policy   = data.aws_iam_policy_document.terraform_role_trust.json
  max_session_duration = 3600

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
    Purpose   = "TerraformCI"
  }
}

data "aws_iam_policy_document" "terraform_permissions" {
  statement {
    sid    = "ManageNetworking"
    effect = "Allow"

    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateNetworkInterface",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteVpc",
      "ec2:DeleteVpcEndpoints",
      "ec2:Describe*",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateAddress",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageEKS"
    effect = "Allow"

    actions = [
      "eks:AssociateAccessPolicy",
      "eks:CreateAccessEntry",
      "eks:CreateAddon",
      "eks:CreateCluster",
      "eks:CreateNodegroup",
      "eks:DeleteAccessEntry",
      "eks:DeleteAddon",
      "eks:DeleteCluster",
      "eks:DeleteNodegroup",
      "eks:DescribeAccessEntry",
      "eks:DescribeAddon",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:DisassociateAccessPolicy",
      "eks:List*",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:UpdateAccessEntry",
      "eks:UpdateAddon",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageECR"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteLifecyclePolicy",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:PutLifecyclePolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/qrify*"
    ]
  }

  statement {
    sid    = "ManageQRifyS3"
    effect = "Allow"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketWebsite",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketAcl",
      "s3:PutBucketCORS",
      "s3:PutBucketLogging",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketWebsite",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration"
    ]

    resources = [
      "arn:aws:s3:::qrify-*"
    ]
  }

  statement {
    sid    = "ManageQRifyS3Objects"
    effect = "Allow"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::qrify-*/*"
    ]
  }

  statement {
    sid    = "ManageLoadBalancing"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:*",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DeleteTags",
      "autoscaling:Describe*",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageObservability"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageDNSAndCertificates"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
      "acm:AddTagsToCertificate",
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "acm:RemoveTagsFromCertificate",
      "acm:RequestCertificate"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageQRifyRoles"
    effect = "Allow"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/QRify*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/qrify-*"
    ]
  }

  statement {
    sid    = "ManageQRifyPolicies"
    effect = "Allow"

    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyTags",
      "iam:ListPolicyVersions",
      "iam:SetDefaultPolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/QRify*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/qrify-*"
    ]
  }

  statement {
    sid    = "PassQRifyRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/QRify*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/qrify-*"
    ]
  }

  statement {
    sid    = "ReadIAMMetadata"
    effect = "Allow"

    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
      "iam:ListRoles",
      "iam:ListPolicies"
    ]

    resources = ["*"]
  }

  # EKS IRSA OIDC provider (aws_iam_openid_connect_provider in modules/eks).
  statement {
    sid    = "ManageEKSOidcProviders"
    effect = "Allow"

    actions = [
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint"
    ]

    resources = ["*"]
  }

  # EKS CreateNodegroup validates this service-linked role via iam:GetRole.
  statement {
    sid    = "ReadEKSNodegroupServiceLinkedRole"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
    ]
  }

  statement {
    sid    = "CreateEKSNodegroupServiceLinkedRole"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["eks-nodegroup.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "terraform" {
  name        = "QRifyTerraformPolicy"
  description = "Permissions required by QRify Terraform automation"
  policy      = data.aws_iam_policy_document.terraform_permissions.json

  tags = {
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform.arn
}

output "terraform_role_arn" {
  description = "ARN of the role assumed by GitHub Actions"
  value       = aws_iam_role.terraform.arn
}