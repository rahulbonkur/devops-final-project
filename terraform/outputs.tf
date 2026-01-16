output "recipe_slave_public_ip" {
  value = aws_instance.recipe_slave.public_ip
}

output "recipe_app_url" {
  value = "http://${aws_instance.recipe_slave.public_ip}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "ai_chatbot_alb_dns" {
  value = aws_lb.ai_chatbot.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ai_chatbot.repository_url
}
