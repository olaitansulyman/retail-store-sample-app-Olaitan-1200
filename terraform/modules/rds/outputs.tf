output "mysql_endpoint" {
  description = "MySQL endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "postgres_endpoint" {
  description = "PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "mysql_database" {
  description = "MySQL database name"
  value       = aws_db_instance.mysql.db_name
}

output "postgres_database" {
  description = "PostgreSQL database name"
  value       = aws_db_instance.postgres.db_name
}
