output "load_balancer_target_group_arn" {
  value       = aws_lb_target_group.main.arn
  description = "The arn of the load balancer target group to be associated with the ecs"
}