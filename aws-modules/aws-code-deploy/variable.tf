variable "auto_scaling_group" {}
variable "load_balancer" {}
variable "environment" {}
variable "lb_target_group" {}
variable "termination_wait_time_in_minutes" {
    type = number
    default = 60
}
