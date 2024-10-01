output "application_roles_ecs_deployment_role_name" {
  value       = module.application_roles.ecs_deployment_role_name
  description = "The name of the ecs deployment role"
}

output "application_roles_ecs_task_execution_role_arn" {
  value       = module.application_roles.ecs_task_execution_role_arn
  description = "The arn of the ecs task execution role"
}

output "application_roles_ecs_task_execution_role_id" {
  value       = module.application_roles.ecs_task_execution_role_id
  description = "The id of the ecs task execution role"
}

output "application_roles_ecs_task_role_arn" {
  value       = module.application_roles.ecs_task_role_arn
  description = "The arn of the ecs task role"
}

output "application_secrets_govuk_notify_api_key_secret_arn" {
  value       = module.application_secrets.govuk_notify_api_key_secret_arn
  description = "The arn of the govuk notify api key secret"
}

output "application_secrets_openai_api_key_secret_arn" {
  value       = module.application_secrets.openai_api_key_secret_arn
  description = "The arn of the openai api key secret"
}

output "application_secrets_os_data_key_secret_arn" {
  value       = module.application_secrets.os_data_key_secret_arn
  description = "The arn of the os data key secret"
}

output "application_secrets_rails_master_key_secret_arn" {
  value       = module.application_secrets.rails_master_key_secret_arn
  description = "The arn of the rails master key secret"
}

output "application_secrets_review_app_user_password_secret_arn" {
  value       = module.application_secrets.review_app_user_password_secret_arn
  description = "Password for seeded review app users"
}

output "application_secrets_sentry_dsn_secret_arn" {
  value       = module.application_secrets.sentry_dsn_secret_arn
  description = "The arn of the sentry dsn secret"
}

output "application_security_group_ecs_security_group_id" {
  value       = module.application_security_group.ecs_security_group_id
  description = "The id of the ecs security group"
}

output "application_security_group_redis_security_group_id" {
  value       = module.application_security_group.redis_security_group_id
  description = "The id of the redis security group"
}

output "application_secrets_staging_performance_test_email_secret_arn" {
  value       = module.application_secrets.staging_performance_test_email_secret_arn
  description = "The arn of the staging performance test email secret"
}

output "application_secrets_staging_performance_test_password_secret_arn" {
  value       = module.application_secrets.staging_performance_test_password_secret_arn
  description = "The arn of the staging performance test password secret"
}

output "bulk_upload_details" {
  value       = module.bulk_upload.details
  description = "Details block of the bulk upload bucket for the application to use to connect"
}

output "cds_export_details" {
  value       = module.cds_export.details
  description = "Details block of the cds export bucket for the application to use to connect"
}

output "certificates_cloudfront_certificate_validation" {
  value       = module.certificates.cloudfront_certificate_validation
  description = "The domain validation objects for the cloudfront certificate"
}

output "certificates_load_balancer_certificate_validation" {
  value       = module.certificates.load_balancer_certificate_validation
  description = "The domain validation objects for the load balancer certificate"
}

output "collection_resources_details" {
  value       = module.collection_resources.details
  description = "Details block of the collection resources bucket for the application to use to connect"
}

output "database_rds_partial_connection_string_parameter_name" {
  value       = module.database.rds_partial_connection_string_parameter_name
  description = "The name of the partial database connection string in the parameter store"
}

output "deployment_role_arn" {
  value       = module.deployment_role.deployment_role_arn
  description = "Arn of the terraform deployment role"
}

output "front_door_cloudfront_header_name" {
  value       = module.front_door.cloudfront_header_name
  description = "The name of the custom header used for cloudfront"
}

output "front_door_cloudfront_header_password" {
  value       = module.front_door.cloudfront_header_password
  description = "The password on the custom header used for cloudfront"
  sensitive   = true
}

output "front_door_load_balancer_arn_suffix" {
  value       = module.front_door.load_balancer_arn_suffix
  description = "The arn suffix of the load balancer"
}

output "front_door_load_balancer_listener_arn" {
  value       = module.front_door.load_balancer_listener_arn
  description = "The arn of the load balancer listener"
}

output "monitoring_sns_topic_arn" {
  value       = module.monitoring_topic_main.sns_topic_arn
  description = "The arn of the main sns topic for monitoring"
}

output "networking_private_subnet_ids" {
  value       = module.networking.private_subnet_ids
  description = "The ids of all the private subnets"
}

output "networking_redis_private_subnet_group_name" {
  value       = module.networking.redis_private_subnet_group_name
  description = "The name of the private subnet group for redis"
}

output "networking_vpc_id" {
  value       = module.networking.vpc_id
  description = "The id of the main vpc"
}
