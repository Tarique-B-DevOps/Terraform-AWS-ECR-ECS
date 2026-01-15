# Terraform AWS ECR ECS Module

A comprehensive, production-ready Terraform module for deploying containerized applications on AWS using Amazon ECS (Elastic Container Service), ECR (Elastic Container Registry), and ALB (Application Load Balancer). This module provides reusable, modular infrastructure components for building scalable containerized applications on AWS.

## Features

- **ECR Module**: Create and manage Docker container image repositories
- **ECS Module**: Deploy containerized applications with ECS clusters, task definitions, and services
- **ALB Module**: Set up Application Load Balancers for traffic distribution
- **IAM Integration**: Automatic IAM role creation with configurable managed policies
- **Security Groups**: Pre-configured security groups for ECS tasks and ALB
- **CloudWatch Logs**: Automatic log group creation for container logs
- **Fargate Support**: Native support for AWS Fargate launch type
- **Modular Design**: Separate modules for maximum reusability and flexibility

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create ECS, ECR, ALB, VPC, and IAM resources

## Architecture

This module creates the following AWS resources:

1. **VPC**: Virtual Private Cloud with public subnets (uses external VPC module)
2. **ECR Repository**: Docker image storage and management
3. **ALB**: Application Load Balancer for traffic routing
4. **ECS Cluster**: Container orchestration cluster
5. **ECS Task Definition**: Container configuration and resource allocation
6. **ECS Service**: Running container instances
7. **IAM Roles**: Task execution and task roles with managed policies
8. **Security Groups**: Network security for ECS and ALB
9. **CloudWatch Log Groups**: Centralized logging

## Quick Start

### Basic Usage

```hcl
module "vpc" {
  source = "git::https://github.com/Tarique-B-DevOps/Terraform-AWS-VPC-EKS.git//modules/vpc?ref=main"
  
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = {
    "sub1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    "sub2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
  private_subnets       = {}
  provision_nat_gateway = false
  environment           = "dev"
}

module "ecr" {
  source = "./modules/ecr"
  
  repository_name      = "my-app"
  image_tag_mutability = "MUTABLE"
  scan_on_push        = false
}

module "alb" {
  source = "./modules/alb"
  
  name_prefix    = "my-app"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  internal       = false
  target_port    = 80
  listener_port  = 80
  health_check_path = "/"
  listener_rule_path_pattern = "/*"
}

module "ecs" {
  source = "./modules/ecs"
  
  name_prefix      = "my-app"
  cluster_name     = "my-app"
  region           = "us-east-1"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  assign_public_ip = true
  
  container_name  = "my-app"
  container_image = "public.ecr.aws/nginx/nginx:latest"
  container_port  = 80
  
  launch_type   = "FARGATE"
  desired_count = 1
  task_cpu      = "1024"
  task_memory   = "2048"
  
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  
  create_task_role = true
  task_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}
```

## Module Documentation

### ECR Module

The ECR module creates and manages Docker container image repositories.

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| repository_name | Name of the ECR repository | `string` | n/a | yes |
| image_tag_mutability | Tag mutability setting | `string` | `"MUTABLE"` | no |
| scan_on_push | Enable image scanning on push | `bool` | `false` | no |

#### Outputs

| Name | Description |
|------|-------------|
| repository_url | URL of the ECR repository |
| repository_arn | ARN of the ECR repository |
| repository_name | Name of the ECR repository |

#### Example

```hcl
module "ecr" {
  source = "./modules/ecr"
  
  repository_name      = "my-app"
  image_tag_mutability = "MUTABLE"
  scan_on_push        = true
}
```

### ALB Module

The ALB module creates Application Load Balancers with target groups, listeners, and security groups.

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for naming resources | `string` | n/a | yes |
| vpc_id | VPC ID where ALB will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for ALB | `list(string)` | n/a | yes |
| internal | Whether the ALB is internal | `bool` | `false` | no |
| target_port | Port on which targets receive traffic | `number` | `80` | no |
| listener_port | Port for the ALB listener | `number` | `80` | no |
| health_check_path | Health check path | `string` | `"/"` | no |
| listener_rule_path_pattern | Path pattern for listener rule | `string` | `null` | no |
| enable_deletion_protection | Enable deletion protection | `bool` | `false` | no |
| allowed_cidr_blocks | CIDR blocks allowed to access ALB | `list(string)` | `["0.0.0.0/0"]` | no |

#### Outputs

| Name | Description |
|------|-------------|
| alb_arn | ARN of the Application Load Balancer |
| alb_dns_name | DNS name of the ALB |
| alb_zone_id | Zone ID of the ALB |
| target_group_arn | ARN of the target group |
| target_group_id | ID of the target group |
| listener_arn | ARN of the ALB listener |
| security_group_id | ID of the ALB security group |

#### Example

```hcl
module "alb" {
  source = "./modules/alb"
  
  name_prefix    = "my-app"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  internal       = false
  target_port    = 8080
  listener_port  = 80
  health_check_path = "/health"
  listener_rule_path_pattern = "/*"
}
```

### ECS Module

The ECS module creates ECS clusters, task definitions, services, IAM roles, and security groups.

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for naming resources | `string` | n/a | yes |
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| region | AWS region | `string` | n/a | yes |
| vpc_id | VPC ID where resources will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for ECS tasks | `list(string)` | n/a | yes |
| container_name | Name of the container | `string` | n/a | yes |
| container_image | Docker image for the container | `string` | n/a | yes |
| container_port | Port on which container listens | `number` | `80` | no |
| launch_type | Launch type (FARGATE or EC2) | `string` | `"FARGATE"` | no |
| desired_count | Number of tasks to run | `number` | `1` | no |
| task_cpu | CPU units for the task | `string` | `"1024"` | no |
| task_memory | Memory for the task in MB | `string` | `"2048"` | no |
| assign_public_ip | Whether to assign public IP | `bool` | `true` | no |
| target_group_arn | ARN of target group (optional) | `string` | `null` | no |
| alb_security_group_id | Security group ID of ALB | `string` | `null` | no |
| create_task_role | Whether to create task role | `bool` | `false` | no |
| task_role_managed_policy_arns | List of managed policy ARNs | `list(string)` | `[]` | no |
| enable_container_insights | Enable Container Insights | `bool` | `false` | no |
| log_retention_in_days | Log retention in days | `number` | `14` | no |

#### Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| service_id | ID of the ECS service |
| service_name | Name of the ECS service |
| service_arn | ARN of the ECS service |
| task_definition_arn | ARN of the task definition |
| task_execution_role_arn | ARN of the task execution role |
| task_role_arn | ARN of the task role (if created) |
| ecs_security_group_id | ID of the ECS security group |
| log_group_name | Name of the CloudWatch log group |

#### Example

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  name_prefix      = "my-app"
  cluster_name     = "my-app"
  region           = "us-east-1"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  
  container_name  = "my-app"
  container_image = "${module.ecr.repository_url}:latest"
  container_port  = 8080
  
  launch_type   = "FARGATE"
  desired_count = 2
  task_cpu      = "2048"
  task_memory   = "4096"
  
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  
  create_task_role = true
  task_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
  
  enable_container_insights = true
  log_retention_in_days     = 30
}
```

## Advanced Configuration

### Using Custom Container Images

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  container_image = "${module.ecr.repository_url}:v1.0.0"
  
  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = "production"
    },
    {
      name  = "API_KEY"
      value = "your-api-key"
    }
  ]
  
  container_secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:region:account:secret:db-password"
    }
  ]
}
```

### ECS Service Without ALB

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  target_group_arn      = null
  alb_security_group_id = null
  
  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

### Custom Health Checks

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  health_check = {
    command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
    interval    = 30
    timeout     = 5
    retries     = 3
    startPeriod = 60
  }
}
```

### Multiple Capacity Providers

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
    }
  ]
}
```

## Variables Reference

### Root Module Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` |
| public_subnets | Map of public subnets | `map(object)` | See variables.tf |
| private_subnets | Map of private subnets | `map(object)` | `{}` |
| provision_nat_gateway | Provision NAT Gateway | `bool` | `false` |
| environment | Environment name | `string` | `"dev"` |
| region | AWS region | `string` | `"us-east-1"` |
| name_prefix | Prefix for naming | `string` | `"ecs-app"` |
| container_image | Docker image URI | `string` | `"public.ecr.aws/nginx/nginx:latest"` |
| container_port | Container port | `number` | `80` |
| launch_type | Launch type | `string` | `"FARGATE"` |
| desired_count | Number of tasks | `number` | `1` |
| health_check_path | Health check path | `string` | `"/"` |

## Outputs Reference

### Root Module Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| ecr_repository_url | URL of the ECR repository |
| ecr_repository_arn | ARN of the ECR repository |
| ecs_cluster_id | ID of the ECS cluster |
| ecs_service_name | Name of the ECS service |
| alb_dns_name | DNS name of the ALB |
| alb_arn | ARN of the ALB |

## Best Practices

1. **Security**: Always use IAM roles with least privilege principles. Only attach necessary managed policies to task roles.

2. **Networking**: Use private subnets for ECS tasks when possible and route traffic through ALB only.

3. **Logging**: Enable CloudWatch Container Insights for better observability in production environments.

4. **Image Scanning**: Enable `scan_on_push` in ECR for security vulnerability detection.

5. **Resource Sizing**: Adjust `task_cpu` and `task_memory` based on your application requirements. Fargate has specific CPU/memory combinations.

6. **High Availability**: Deploy tasks across multiple availability zones by using subnets in different AZs.

7. **Health Checks**: Configure appropriate health check paths and intervals for your application.

8. **Cost Optimization**: Use Fargate Spot for non-critical workloads to reduce costs.

## Troubleshooting

### Common Issues

**Issue**: ECS tasks failing to start
- Check IAM role permissions
- Verify container image exists and is accessible
- Review CloudWatch logs for container errors

**Issue**: ALB health checks failing
- Ensure health check path is correct
- Verify security group rules allow traffic
- Check container is listening on the correct port

**Issue**: Tasks not registering with target group
- Verify `target_group_arn` is correctly passed
- Check network configuration and security groups
- Ensure tasks are in RUNNING state