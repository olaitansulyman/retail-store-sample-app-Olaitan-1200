output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = module.s3_lambda.bucket_name
}

output "rds_mysql_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.mysql_endpoint
}

output "rds_postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.postgres_endpoint
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.s3_lambda.lambda_function_name
}

output "developer_user_arn" {
  description = "Developer IAM user ARN"
  value       = module.iam.developer_user_arn
}

output "developer_access_key_id" {
  description = "Developer access key ID"
  value       = module.iam.developer_access_key_id
  sensitive   = true
}

output "developer_secret_access_key" {
  description = "Developer secret access key"
  value       = module.iam.developer_secret_access_key
  sensitive   = true
}
