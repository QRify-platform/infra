output "ecr_repo_urls" {
  value = {
    for k, repo in aws_ecr_repository.qrify : k => repo.repository_url
  }
}
