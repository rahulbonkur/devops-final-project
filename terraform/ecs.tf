resource "aws_ecs_service" "ai_chatbot" {
  name            = "ai-chatbot-service"
  cluster         = aws_ecs_cluster.ai_chatbot.id
  task_definition = aws_ecs_task_definition.ai_chatbot.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100

    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
  }

  network_configuration {
    subnets          = aws_subnet.public[*].id   # ✅ FIXED
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ai_chatbot.arn
    container_name   = "ai-chatbot"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.ai_chatbot,
    aws_cloudwatch_log_group.ai_chatbot
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "ai-chatbot-service"
    }
  )
}
