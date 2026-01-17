resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_cp" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = lookup(default_capacity_provider_strategy.value, "base", null)
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_ecs_task_definition" "task_def" {
  family                   = var.name_prefix
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = var.create_task_role ? aws_iam_role.ecs_task_role[0].arn : null
  network_mode             = "awsvpc"
  requires_compatibilities = [var.launch_type]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  runtime_platform {
    operating_system_family = var.runtime_platform_operating_system_family
    cpu_architecture        = var.runtime_platform_cpu_architecture
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = var.container_environment
      secrets     = var.container_secrets
      healthCheck = var.health_check != null ? var.health_check : null
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = var.name_prefix
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_def.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  force_new_deployment  = var.force_new_deployment
  wait_for_steady_state = var.wait_for_steady_state

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registry_arn != null ? [1] : []
    content {
      registry_arn = var.service_registry_arn
    }
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}
