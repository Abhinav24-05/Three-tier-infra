resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  lifecycle_policy {
    policy = jsonencode({
      rules = [
        { rulePriority = 1, description = "keep last 10", selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 10 }, action = { type = "expire" } }
      ]
    })
  }
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}
