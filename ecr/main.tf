resource "aws_ecr_repository" "qrify" {
  for_each = toset(var.repository_names)

  name = each.value

  image_tag_mutability = "MUTABLE" # Add this line

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image_tag_mutability]
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}


resource "aws_ecr_lifecycle_policy" "qrify" {
  for_each = toset(var.repository_names)

  repository = aws_ecr_repository.qrify[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
