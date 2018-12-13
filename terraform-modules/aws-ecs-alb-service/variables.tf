variable "environment" {
  default = ""
}

variable "name" {}

variable "region" {}

variable "alb_arn_suffix" {
  default = ""
}

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

variable "service_check_path" {
  default = "/"
}

variable "service_route_path" {
  type    = "list"
  default = [""]
}

variable "service_route_host" {
  type    = "list"
  default = [""]
}

variable "service_response" {
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

variable "zone_id" {
  default = ""
}

variable "alb_domain_name" {
  default = ""
}

variable "alb_zone_id" {
  default = ""
}

variable "deregistration_delay" {
  default = "300"
}

variable "alarm_cpu_threshold_high" {
  default = "75"
}

variable "alarm_cpu_threshold_low" {
  default = "50"
}

variable "kms_key_alias" {}
