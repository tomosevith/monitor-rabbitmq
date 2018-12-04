variable "environment" {}
variable "name" {}
variable "key_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "asg_min" {}
variable "asg_max" {}
variable "asg_desired" {}
variable "aws_asg_name" {}

variable "user_data" {
  default = ""
}

variable "public_ip" {
  default = false
}

variable "ebs_optimized" {
  default = false
}

variable "heartbeat_timeout" {
  default = "180"
}

variable "subnet_id" {
  type = "list"
}

variable "security_group_id" {}

variable "alarm_memory_threshold_low" {
  default = "60"
}

variable "alarm_memory_threshold_high" {
  default = "75"
}

variable "protect_from_scale_in" {
  default = false
}

variable "spot_price" {
  default = 0
}

variable "docker_volume_size" {
  default = 22
}
