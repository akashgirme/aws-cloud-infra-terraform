
output "rds_security_group" {
  value = aws_security_group.rds_security_group
}

output "redis_security_group" {
  value = aws_security_group.redis_security_group
}

output "launch_template_security_group" {
  value = aws_security_group.launch_template_security_group
}

output "load_balancer_security_group" {
  value = aws_security_group.load_balancer_security_group
}

# output "bastian_host_security_group" {
#   value = aws_security_group.bastian_host_security_group
# }