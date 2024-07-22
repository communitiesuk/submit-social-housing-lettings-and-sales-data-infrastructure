resource "aws_ecr_lifecycle_policy" "core_production_policy" {
  repository = aws_ecr_repository.core.name

  policy = <<POLICY
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Retain last 3 production images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["production-"],
          "countType": "imageCountMoreThan",
          "countNumber": 3
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  POLICY
}

resource "aws_ecr_lifecycle_policy" "core_staging_policy" {
  repository = aws_ecr_repository.core.name

  policy = <<POLICY
  {
    "rules": [
      {
        "rulePriority": 2,
        "description": "Retain last 10 staging images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["staging-"],
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  POLICY
}

resource "aws_ecr_lifecycle_policy" "core_review_policy" {
  repository = aws_ecr_repository.core.name

  policy = <<POLICY
  {
    "rules": [
      {
        "rulePriority": 3,
        "description": "Expire review images after 14 days",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["review-"],
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  POLICY
}
