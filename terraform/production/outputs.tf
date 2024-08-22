output "cloudfront_certificate_validation" {
  value       = module.certificates.cloudfront_certificate_validation
  description = "The domain validation objects for the cloudfront certificate"
}

output "load_balancer_certificate_validation" {
  value       = module.certificates.load_balancer_certificate_validation
  description = "The domain validation objects for the load balancer certificate"
}

output "new_cloudfront_certificate_validation" {
  value       = module.certs_for_new_domain.cloudfront_certificate_validation
  description = "The domain validation objects for the cloudfront certificate"
}

output "new_load_balancer_certificate_validation" {
  value       = module.certs_for_new_domain.load_balancer_certificate_validation
  description = "The domain validation objects for the load balancer certificate"
}
