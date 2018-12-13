variable "vpc_id" {
  description = "ID of you vpc service"
  default     = ""
}

variable "name" {}

variable "security_group" {
  default = [""]
}

variable "allowed_ips" {
  default = ["0.0.0.0/0"]
}
