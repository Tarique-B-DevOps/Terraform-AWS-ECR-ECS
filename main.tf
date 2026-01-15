module "vpc" {
  source                = "git::https://github.com/Tarique-B-DevOps/Terraform-AWS-VPC-EKS.git//modules/vpc?ref=main"
  vpc_cidr              = var.vpc_cidr
  public_subnets        = var.public_subnets
  private_subnets       = var.private_subnets
  provision_nat_gateway = var.provision_nat_gateway
  environment           = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.name_prefix
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
}

module "alb" {
  source = "./modules/alb"

  name_prefix                = var.name_prefix
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  internal                   = var.alb_internal
  target_port                = var.container_port
  listener_port              = var.alb_listener_port
  health_check_path          = var.health_check_path
  listener_rule_path_pattern = var.alb_listener_rule_path_pattern
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix      = var.name_prefix
  cluster_name     = var.name_prefix
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  assign_public_ip = var.ecs_assign_public_ip

  container_name  = var.name_prefix
  container_image = var.container_image
  container_port  = var.container_port

  launch_type   = var.launch_type
  desired_count = var.desired_count
  task_cpu      = var.ecs_task_cpu
  task_memory   = var.ecs_task_memory

  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id

  create_task_role              = var.ecs_create_task_role
  task_role_managed_policy_arns = var.ecs_task_role_managed_policy_arns

  depends_on = [module.vpc, module.ecr, module.alb]
}
