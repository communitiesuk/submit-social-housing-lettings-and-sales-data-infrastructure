output "cloudfront_certificate_validation" {
  value       = module.certificates.cloudfront_certificate_validation
  description = "The domain validation objects for the cloudfront certificate"
}
