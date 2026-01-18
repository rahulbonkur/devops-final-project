resource "aws_ecr_repository" "ai_chatbot" {
  name         = "ai-chatbot"
  force_delete = true   # 🔥 THIS IS THE FIX

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = "dev"
    Project     = "DevOps Final Project"
    ManagedBy   = "Terraform"
  }
}
