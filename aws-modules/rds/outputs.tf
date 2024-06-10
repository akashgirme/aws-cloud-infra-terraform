output "rds_database_address" {
  value = aws_db_instance.rds_instance.address
}

output "rds_database_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}