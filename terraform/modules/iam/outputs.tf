output "developer_access_key_id" {
  description = "Developer IAM user access key ID"
  value       = aws_iam_access_key.developer.id
  sensitive   = true
}

output "developer_secret_access_key" {
  description = "Developer IAM user secret access key"
  value       = aws_iam_access_key.developer.secret
  sensitive   = true
}

output "developer_user_arn" {
  description = "Developer IAM user ARN"
  value       = aws_iam_user.developer.arn
}
