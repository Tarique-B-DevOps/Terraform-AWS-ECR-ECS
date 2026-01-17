variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to ECS tasks"
  type        = bool
  default     = true
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "capacity_providers" {
  description = "List of capacity providers for the cluster"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "default_capacity_provider_strategy" {
  description = "The capacity provider strategy to use by default for the cluster"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number)
  }))
  default = []
}

variable "launch_type" {
  description = "Launch type for ECS service (FARGATE or EC2)"
  type        = string
  default     = "FARGATE"
}

variable "force_new_deployment " {
  description = "Specify whether to force a new deployment"
  type        = bool
  default     = false

}

variable "wait_for_steady_state" {
  description = "Specify whether to wait for the steady state of the service"
  type        = bool
  default     = false
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "1024"
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = string
  default     = "2048"
}

variable "runtime_platform_operating_system_family" {
  description = "Operating system family for the runtime platform"
  type        = string
  default     = "LINUX"
}

variable "runtime_platform_cpu_architecture" {
  description = "CPU architecture for the runtime platform"
  type        = string
  default     = "X86_64"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "container_environment" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "health_check" {
  description = "Health check configuration for the container"
  type = object({
    command     = list(string)
    interval    = number
    timeout     = number
    retries     = number
    startPeriod = number
  })
  default = null
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "create_task_role" {
  description = "Whether to create a task role for additional permissions"
  type        = bool
  default     = false
}

variable "task_role_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the task role"
  type        = list(string)
  default     = []
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access ECS tasks (when ALB is disabled)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access ECS tasks (when ALB is disabled)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "target_group_arn" {
  description = "ARN of the target group to attach to the ECS service (optional)"
  type        = string
  default     = null
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB (required if target_group_arn is provided)"
  type        = string
  default     = null
}

variable "service_registry_arn" {
  description = "ARN of the service registry (for service discovery)"
  type        = string
  default     = null
}
