variable "vpc_id" {
  description = "ID of you vpc service"
  default     = ""
}

variable "name" {}

variable "security_group" {
  default = [""]
}
