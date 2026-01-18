resource "aws_ecs_task_definition" "ai_chatbot" {
  family                   = "ai-chatbot-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "ai-chatbot"
      image     = "${aws_ecr_repository.ai_chatbot.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]

      # ✅ ADD THIS BLOCK
      environment = [
        {
          name  = "GROQ_API_KEY"
          value = "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"
        },
        {
          name  = "GROQ_MODEL"
          value = "llama3-70b-8192"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/ai-chatbot"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
