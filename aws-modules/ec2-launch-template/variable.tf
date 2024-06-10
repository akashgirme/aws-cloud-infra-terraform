variable "environment" {}
variable "security_group" {
  description = "List of security group IDs for EC2 instances"
}


variable "ami_id" {
  description = "The ID of the Ubuntu AMI"
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_pair_name" {
  description = "The name of the EC2 key pair for SSH access"
  default     = "akash-key"
}

