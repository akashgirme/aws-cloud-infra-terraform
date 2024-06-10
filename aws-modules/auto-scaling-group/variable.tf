variable "environment" {
  type = string
}
variable "launch_configuration" {}
variable "private_subnets" {}
variable "lb_target_group" {}
variable "load_balancer" {}

variable "auto_scaling_group_min_size" {
  description = "Describes minimum instances, ASG can scale-down to this limit"
  type        = number
  default     = 2
}

variable "auto_scaling_group_max_size" {
  description = "Describes maximum instances, ASG can scale-up to this limit."
  type        = number
  default     = 4
}

variable "auto_scaling_group_desired_capacity" {
  description = "Describes number of instances should available at normal state"
  type        = number
  default     = 2
}

variable "auto_scale_in_cpu_threshold" {
  type        = string
  default     = 70
}

variable "auto_scale_out_cpu_threshold" {
  type = string
  default = "60"
}