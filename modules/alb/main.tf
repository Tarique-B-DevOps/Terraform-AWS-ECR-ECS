resource "aws_lb" "alb" {
  name               = var.name_prefix
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.name_prefix}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  deregistration_delay = var.deregistration_delay
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = var.default_action_type
    target_group_arn = var.default_action_type == "forward" ? aws_lb_target_group.tg.arn : null

    dynamic "fixed_response" {
      for_each = var.default_action_type == "fixed-response" ? [1] : []
      content {
        content_type = var.fixed_response_content_type
        message_body = var.fixed_response_message_body
        status_code  = var.fixed_response_status_code
      }
    }
  }
}

resource "aws_lb_listener_rule" "rule" {
  count        = var.listener_rule_path_pattern != null ? 1 : 0
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    path_pattern {
      values = [var.listener_rule_path_pattern]
    }
  }
}
