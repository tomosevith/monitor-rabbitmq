variable "region" {
  default = "eu-central-1"
}

variable "az_count" {
  default = 2
}

variable "name" {
  default = "videobattle"
}

variable "cidr" {
  default = "10.0.0.0/16"
}
variable "ecs_instance_type"{
  default = "t2.small"
}

variable "ecs_asg_min" {
  default = 1
}

variable "ecs_asg_max" {
  default = 1
}

variable "ecs_asg_desired" {
  default = 1
}
