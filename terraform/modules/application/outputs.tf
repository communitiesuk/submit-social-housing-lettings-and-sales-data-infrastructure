output "load_balancer_target_group_arn_suffix" {
  value       = aws_lb_target_group.this.arn_suffix
  description = "The arn suffix of the load balancer target group"
}
