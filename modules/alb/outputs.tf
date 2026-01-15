output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.tg.arn
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.tg.id
}

output "listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.http_listener.arn
}

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}
