# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ai_chatbot" {
  name              = "/ecs/ai-chatbot"
  retention_in_days = 7

  tags = {
    Name        = "ai-chatbot-logs"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "DevOps Final Project"
  }
}

# ECS Task Definition
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
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "GROQ_API_KEY"
          value = var.groq_api_key
        },
        {
          name  = "GROQ_MODEL"
          value = var.groq_model
        }
      ]
      
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ai_chatbot.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "ai-chatbot-task"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "DevOps Final Project"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ai_chatbot" {
  name = "ai-chatbot-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name        = "ai-chatbot-cluster"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "DevOps Final Project"
  }
}

# ECS Service - USING PUBLIC SUBNETS
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
    subnets          = aws_subnet.public[*].id
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
  
  tags = {
    Name        = "ai-chatbot-service"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "DevOps Fina
