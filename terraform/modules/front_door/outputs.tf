output "load_balancer_security_group_id" {
  value       = aws_security_group.load_balancer.id
  description = "The id of the load balancer security group"
}

output "load_balancer_arn_suffix" {
  value       = aws_lb.this.arn_suffix
  description = "The arn suffix of the load balancer"
}

output "load_balancer_listener_arn" {
  value       = var.initial_create ? null : aws_lb_listener.https[0].arn
  description = "The arn of the load balancer listener"
}

output "cloudfront_header_name" {
  value       = local.cloudfront_header_name
  description = "The name of the custom header used for cloudfront"
}

output "cloudfront_header_password" {
  value       = random_password.cloudfront_header.result
  description = "The password on the custom header used for cloudfront"
  sensitive   = true
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "Cloudfront domain name"
}

output "cloudfront_hosted_zone_id" {
  value       = aws_cloudfront_distribution.this.hosted_zone_id
  description = "Cloudfront hosted zone id"
}
