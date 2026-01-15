variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR blocks and availability zones"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "sub1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    "sub2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  description = "Map of private subnets with CIDR blocks and availability zones (empty if not using private subnets)"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {}
}

variable "provision_nat_gateway" {
  description = "Whether to provision NAT Gateway"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "ecs-app"
}

variable "container_image" {
  description = "Docker image URI for the container"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "launch_type" {
  description = "Launch type for ECS service (FARGATE or EC2)"
  type        = string
  default     = "FARGATE"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/"
}

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push for ECR repository"
  type        = bool
  default     = false
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "alb_listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "alb_listener_rule_path_pattern" {
  description = "Path pattern for ALB listener rule"
  type        = string
  default     = "/*"
}

variable "ecs_assign_public_ip" {
  description = "Whether to assign public IP to ECS tasks"
  type        = bool
  default     = true
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "1024"
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task in MB"
  type        = string
  default     = "2048"
}

variable "ecs_create_task_role" {
  description = "Whether to create a task role for ECS"
  type        = bool
  default     = true
}

variable "ecs_task_role_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the ECS task role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
}
