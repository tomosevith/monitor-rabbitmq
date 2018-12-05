variable "target_group_arn" {}

variable "priority" {
  default = 100
}

variable "http_listener_arn" {}
variable "https_listener_arn" {}

variable "service_hosts" {
  default = []
}
