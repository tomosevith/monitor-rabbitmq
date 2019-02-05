variable "environment" {
  default = ""
}

variable "name" {}

variable "region" {}

variable "cluster_id" {
  default = ""
}

variable "cluster_name" {
  default = ""
}

variable "task_template" {
  default = ""
}

variable "task_role_arn" {
  default = ""
}

variable "desired_count" {
  default = "1"
}

variable "min_capacity" {
  default = "1"
}

variable "max_capacity" {
  default = "2"
}

variable "service_port" {
  default = ""
}

variable "service_memory" {
  default = "200"
}

variable "service_cpu" {
  default = "0"
}

variable "service_name" {
  default = ""
}

variable "service_cmd" {
  default = ""
}

variable "service_entrypoint" {
  default = ""
}

variable "image_url" {
  default = ""
}

variable "aws_bucket" {
  default = ""
}

variable "fqdn" {
  default = ""
}

variable "log_group_name" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "alarm_cpu_threshold_high" {
  default = "75"
}

variable "alarm_cpu_threshold_low" {
  default = "50"
}

variable "kms_key_alias" {}
