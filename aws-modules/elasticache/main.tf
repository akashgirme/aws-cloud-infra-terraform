resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id                 = "${var.environment}-redis-cache"
  engine                     = "redis"
  node_type                  = var.node_type
  num_cache_nodes            = var.num_cache_nodes
  parameter_group_name       = var.parameter_group_name
  engine_version             = var.redis_engine_version
  port                       = 6379
  apply_immediately          = true # Apply Changes Imdiateatly
  auto_minor_version_upgrade = true

  az_mode = var.az_mode

  preferred_availability_zones = ["${var.aws_region}a"]

  security_group_ids = [var.security_group_for_cache.id]
  subnet_group_name  = aws_elasticache_subnet_group.cache_private_subnets_group.name

  depends_on = [var.vpc, aws_elasticache_subnet_group.cache_private_subnets_group, var.security_group_for_cache]
}

resource "aws_elasticache_subnet_group" "cache_private_subnets_group" {
  name       = "${var.environment}-cache-private-subnets-group"
  subnet_ids = var.private_subnets.*.id
  depends_on = [var.private_subnets]

  tags = {
    Name = "cache-private-subnets-group"
  }
}

resource "aws_elasticache_user" "redis_user" {
  user_id       = var.redis_user_id
  user_name     = var.redis_username
  access_string = "on ~* +@all"
  engine        = "REDIS"

  authentication_mode {
    type      = "password"
    passwords = [var.redis_password]
  }
}

# resource "aws_secretsmanager_secret" "redis_password" {
#   name = "${var.environment}-redis_password"
# }

# resource "aws_secretsmanager_secret_version" "redis_password" {
#   secret_id     = aws_secretsmanager_secret.redis_password.id
#   secret_string = var.redis_password
# }



