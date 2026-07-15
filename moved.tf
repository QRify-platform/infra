# Preserve resource identity after module-internal renames.

moved {
  from = module.qrify_s3.aws_s3_bucket_public_access_block.qrify_allow_public
  to   = module.qrify_s3.aws_s3_bucket_public_access_block.qrify
}
