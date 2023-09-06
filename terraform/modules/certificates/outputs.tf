output "certificate_arn" {
  value       = aws_acm_certificate.this.arn
  description = "The arn of the certificate"
}
