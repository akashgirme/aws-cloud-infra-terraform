variable "vpc" {}
variable "security_group" {}
# variable "private_subnet_group" {}
variable "environment" {}
variable "private_subnets" {}


variable "instance_class" {
  description = "Instance type of RDS instance"
  type        = string
  default     = "db.t3.micro"

}

variable "db_name" {
  description = "Name of the Database"
  type        = string

}

variable "db_username" {
  description = "Set Username of database instance required while connecting"
  type        = string
}

variable "db_password" {
  description = "Set strong password, Password is allow to make connection with database"
}

variable "allocated_storage" {
  type    = string
  default = "20"
}

variable "storage_type" {
  description = "Always set storage type to gp3 which is encrypted by default"
  type        = string
  default     = "gp3"

}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "isMultiAZ" {
  description = "Set the Multi-Zonal Availability of RDS instance/ In Production set true & In DEV & UAT set it to false"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  type    = number
  default = 31
  #Valid values are 7 and  multiple of 31

}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "rds_engine_version" {
  type    = string
  default = "12"
}

variable "db_parameter_group_family" {
  type    = string
  default = "postgres12"
}