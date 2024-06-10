
output "load_balancer_public_dns" {
  value = module.load_balancer.load_balancer.dns_name
}

output "rds_database_address" {
  value = module.rds.rds_database_address
}

output "rds_database_endpoint" {
  value = module.rds.rds_database_endpoint
}

output "redis_cluster_endpoint" {
  value = module.cache.redis_cluster_endpoint
}

output "redis_node_address" {
  value = module.cache.redis_node_address
}
