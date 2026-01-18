resource "aws_ecr_repository" "ai_chatbot" {
  name                 = "ai-chatbot"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true  # 🔥 THIS IS THE KEY FIX

  tags = {
    Environment = var.environment
    Project     = "DevOps Final Project"
    ManagedBy   = "Terraform"
  }
}
