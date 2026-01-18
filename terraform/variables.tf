variable "aws_region" {
  default = "ap-south-1"
}

variable "environment" {
  default = "dev"
}

variable "project_name" {
  default = "devops-project"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "jenkins_instance_type" {
  default = "t3.medium"
}

variable "slave_instance_type" {
  default = "t3.small"
}

variable "mykey" {
  description = "EC2 Key pair name"
}

variable "groq_api_key" {
  description = "Groq API Key for AI Chatbot"
  type        = string
  sensitive   = true
}

variable "groq_model" {
  description = "Groq Model"
  type        = string
  default     = "llama3-70b-8192"
}
