data "aws_caller_identity" "current" {}

resource "aws_iam_role" "codebuild_role" {
  name = "ai-chatbot-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:*",
        "ecr:*",
        "ecs:UpdateService",
        "s3:GetObject"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_codebuild_project" "ai_chatbot" {
  name         = "ai-chatbot"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts { type = "NO_ARTIFACTS" }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/rahulbonkur/devops-final-project.git"
    buildspec = "app1-ai-chatbot/buildspec.yml"
  }

  source_version = "main"
}
