variable "cloudfront_domain_name" {
  type        = string
  description = "Then domain name of the cloudfront distribution"
}

variable "cloudfront_additional_names" {
  type        = list(string)
  description = "Additional names to add to the cloudfront certificate"
  default     = []
}

variable "load_balancer_domain_name" {
  type        = string
  description = "Then domain name of the load balancer"
}
