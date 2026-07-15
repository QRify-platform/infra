# Preserve existing resource identity after the bootstrap module split.

moved {
  from = aws_s3_bucket.terraform_state
  to   = module.state_bucket.aws_s3_bucket.terraform_state
}

moved {
  from = aws_s3_bucket_versioning.terraform_state
  to   = module.state_bucket.aws_s3_bucket_versioning.terraform_state
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.terraform_state
  to   = module.state_bucket.aws_s3_bucket_server_side_encryption_configuration.terraform_state
}

moved {
  from = aws_s3_bucket_public_access_block.terraform_state
  to   = module.state_bucket.aws_s3_bucket_public_access_block.terraform_state
}

moved {
  from = aws_s3_bucket_policy.terraform_state
  to   = module.state_bucket.aws_s3_bucket_policy.terraform_state
}

moved {
  from = aws_iam_openid_connect_provider.github
  to   = module.github_oidc.aws_iam_openid_connect_provider.github
}

moved {
  from = aws_iam_role.terraform
  to   = module.terraform_role.aws_iam_role.terraform
}

moved {
  from = aws_iam_policy.terraform
  to   = module.terraform_role.aws_iam_policy.terraform
}

moved {
  from = aws_iam_role_policy_attachment.terraform
  to   = module.terraform_role.aws_iam_role_policy_attachment.terraform
}

moved {
  from = aws_iam_role.ecr_push
  to   = module.ecr_push_role.aws_iam_role.ecr_push
}

moved {
  from = aws_iam_policy.ecr_push
  to   = module.ecr_push_role.aws_iam_policy.ecr_push
}

moved {
  from = aws_iam_role_policy_attachment.ecr_push
  to   = module.ecr_push_role.aws_iam_role_policy_attachment.ecr_push
}

moved {
  from = aws_iam_role.eks_access
  to   = module.eks_access_role.aws_iam_role.eks_access
}

moved {
  from = aws_iam_policy.eks_access
  to   = module.eks_access_role.aws_iam_policy.eks_access
}

moved {
  from = aws_iam_role_policy_attachment.eks_access
  to   = module.eks_access_role.aws_iam_role_policy_attachment.eks_access
}

moved {
  from = aws_route53_zone.primary
  to   = module.dns.aws_route53_zone.primary
}
