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
