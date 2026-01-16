resource "aws_ecr_repository" "ai_chatbot" {
  name                 = "ai-chatbot"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
