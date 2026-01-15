variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "default_action_type" {
  description = "Default action type for ALB listener (forward or fixed-response)"
  type        = string
  default     = "fixed-response"
}

variable "fixed_response_content_type" {
  description = "Content type for fixed response"
  type        = string
  default     = "text/plain"
}

variable "fixed_response_message_body" {
  description = "Message body for fixed response"
  type        = string
  default     = "Not Found"
}

variable "fixed_response_status_code" {
  description = "Status code for fixed response"
  type        = string
  default     = "404"
}

variable "listener_rule_path_pattern" {
  description = "Path pattern for ALB listener rule (e.g., '/*')"
  type        = string
  default     = null
}

variable "listener_rule_priority" {
  description = "Priority for ALB listener rule"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 2
}

variable "health_check_matcher" {
  description = "HTTP status codes that indicate a healthy target"
  type        = string
  default     = "200-399"
}

variable "deregistration_delay" {
  description = "Amount of time for targets to drain connections"
  type        = number
  default     = 300
}
