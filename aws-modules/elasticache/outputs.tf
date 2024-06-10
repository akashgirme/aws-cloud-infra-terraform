
output "redis_cluster_endpoint" {
  value = aws_elasticache_cluster.redis_cache.cache_nodes[0].address
}

output "redis_node_address" {
  value = aws_elasticache_cluster.redis_cache.cluster_address
}
