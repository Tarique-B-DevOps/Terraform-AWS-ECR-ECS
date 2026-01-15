vpc_cidr = "10.0.0.0/16"

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

private_subnets = {}

provision_nat_gateway = false

environment = "dev"

region = "us-east-1"

name_prefix = "nginx"

container_image = "public.ecr.aws/nginx/nginx:latest"

container_port = 80

launch_type = "FARGATE"

desired_count = 1

health_check_path = "/"

ecr_image_tag_mutability = "MUTABLE"

ecr_scan_on_push = false

alb_internal = false

alb_listener_port = 80

alb_listener_rule_path_pattern = "/*"

ecs_assign_public_ip = true

ecs_task_cpu = "1024"

ecs_task_memory = "2048"

ecs_create_task_role = true

ecs_task_role_managed_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
]
