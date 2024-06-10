variable "environment" {}
variable "aws_region" {}
variable "security_group_for_cache" {}
# variable "private_subnet_group" {}
variable "vpc" {}
variable "private_subnets" {}

variable "node_type" {
  description = "Describes the instance type of cache."
  type        = string
  default     = "cache.t2.micro"
}

variable "num_cache_nodes" {
  description = "Number of Cache Nodes we require"
  type        = number
  default     = 1
}

variable "redis_engine_version" {
  description = "Version of REDIS"
  type        = string
  default     = "7.1"
}

variable "az_mode" {
  description = "Type of Availability Zone of Cache Instance"
  type        = string
  default     = "single-az" # Valid options => single-az/multi-az
}

variable "parameter_group_name" {
  type    = string
  default = "default.redis7"
}

variable "redis_password" {
  description = "Password use while making connection with Cache should be 16-128 characters"
  type        = string
  # Password length should be 16-128 characters
}

variable "redis_user_id" {
  description = "userid of cache"
  type        = string
}
variable "redis_username" {
  description = "Username required while making connection with redis"
  type        = string
}

