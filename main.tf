terraform {
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }
}


terraform {
  backend "s3" {
    bucket = "skillstreet-terraform-state-file"
    key    = "terraform"
    region = "us-east-1"
  }
}


provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
}

module "vpc" {
  source = "./aws-modules/vpc"

  # Passing variables to module from .tfvars file.
  aws_region  = var.aws_region
  environment = var.environment
}

module "security_groups" {
  source = "./aws-modules/security-groups"

  # Passing variables from another module to inside the module.
  vpc         = module.vpc.vpc
  environment = var.environment
}


# module "s3" {
#   source = "./aws-modules/s3"

# # Passing variables to module from .tfvars file.
#   bucket_names = var.bucket_names
# }


module "rds" {
  source = "./aws-modules/rds"

  # Passing variables from another module to inside the module.
  vpc             = module.vpc.vpc
  security_group  = module.security_groups.rds_security_group
  private_subnets = module.vpc.private_subnets

  # Passing variables to module from .tfvars file.
  environment                           = var.environment
  instance_class                        = var.instance_class
  rds_engine_version                    = var.rds_engine_version
  db_name                               = var.db_name
  db_username                           = var.db_username
  db_password                           = var.db_password
  allocated_storage                     = var.allocated_storage
  storage_type                          = var.storage_type
  storage_encrypted                     = var.storage_encrypted
  isMultiAZ                             = var.isMultiAZ
  performance_insights_retention_period = var.performance_insights_retention_period
}

module "cache" {
  source = "./aws-modules/elasticache"

  # Passing variables from another module to inside the module.
  security_group_for_cache = module.security_groups.redis_security_group
  vpc                      = module.vpc.vpc
  private_subnets          = module.vpc.private_subnets

  # Passing variables to module from .tfvars file.
  aws_region           = var.aws_region
  environment          = var.environment
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  redis_engine_version = var.redis_engine_version
  az_mode              = var.az_mode
  redis_password       = var.redis_password
  redis_user_id        = var.redis_user_id
  redis_username       = var.redis_username
}



module "launch_template" {
  source = "./aws-modules/ec2-launch-template"

  # Passing variables from another module to inside the module.
  security_group = module.security_groups.launch_template_security_group

  # Passing variables to module from .tfvars file.
  environment   = var.environment
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name
}

module "auto_scaling_group" {
  source = "./aws-modules/auto-scaling-group"

  # Passing variables from another module to inside the module.
  launch_configuration = module.launch_template.launch_configuration
  private_subnets      = module.vpc.private_subnets
  lb_target_group      = module.load_balancer.lb_target_group
  load_balancer        = module.load_balancer.load_balancer

  # Passing variables to module from .tfvars file.
  environment                         = var.environment
  auto_scaling_group_min_size         = var.auto_scaling_group_min_size
  auto_scaling_group_max_size         = var.auto_scaling_group_max_size
  auto_scaling_group_desired_capacity = var.auto_scaling_group_desired_capacity
  auto_scale_in_cpu_threshold = var.auto_scale_in_cpu_threshold
  auto_scale_out_cpu_threshold = var.auto_scale_out_cpu_threshold
}

module "load_balancer" {
  source = "./aws-modules/load-balancer"

  # Passing variables from another module to inside the module.
  vpc                = module.vpc.vpc
  auto_scaling_group = module.auto_scaling_group.auto_scaling_group
  public_subnets     = module.vpc.public_subnets
  security_group     = module.security_groups.load_balancer_security_group
  # lb_connection_logs_bucket = module.s3.lb_connection_logs_bucket

  # Passing variables to module from .tfvars file.
  environment          = var.environment
  ssl_policy           = var.ssl_policy
  ssl_certificiate_arn = var.ssl_certificiate_arn
}


module "code_deploy" {
  source             = "./aws-modules/aws-code-deploy"

  # Passing variables from another module to inside the module.
  auto_scaling_group = module.auto_scaling_group.auto_scaling_group
  load_balancer      = module.load_balancer.load_balancer
  environment        = var.environment
  lb_target_group    = module.load_balancer.lb_target_group

  # Passing variables to module from .tfvars file.
  termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
}



## VARIABLE DECLARATION FOR MODULES 
#VPC

variable "vpc_cidr" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}

# # S3
# variable "bucket_names"{} 

# RDS
variable "instance_class" {}
variable "rds_engine_version" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "allocated_storage" {}
variable "storage_encrypted" {}
variable "storage_type" {}
variable "isMultiAZ" {}
variable "db_parameter_group_family" {}
variable "performance_insights_retention_period" {}

# ELASTICACHE
variable "node_type" {}
variable "num_cache_nodes" {}
variable "redis_engine_version" {}
variable "az_mode" {}
variable "redis_password" {}
variable "redis_user_id" {}
variable "redis_username" {}

# LOAD-BALANCER
variable "ssl_policy" {}
variable "ssl_certificiate_arn" {}

# LAUNCH-TEMPLATE
variable "ami_id" {}
variable "instance_type" {}
variable "key_pair_name" {}

# AUTO-SCALING-GROUP
variable "auto_scaling_group_min_size" {}
variable "auto_scaling_group_max_size" {}
variable "auto_scaling_group_desired_capacity" {}
variable "auto_scale_in_cpu_threshold" {}
variable "auto_scale_out_cpu_threshold" {}

# CODE-DEPLOY
variable "termination_wait_time_in_minutes" {}