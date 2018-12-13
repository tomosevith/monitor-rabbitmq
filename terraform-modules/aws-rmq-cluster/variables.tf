variable "vpc_id" {}

variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "rabbit"
}

variable "environment" {
  default = ""
}

variable "rmq_admin_password" {
  default = "rabbitmq"
}

variable "rmq_password" {
  default = "rabbitmq"
}

variable "count" {
  description = "Number of RabbitMQ nodes"
  default     = 2
}

variable "private_subnets" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

variable "cluster_security_groups" {
  description = "Security groups which should have access to cluster"
  type        = "list"
  default     = []
}

variable "node_security_groups" {
  description = "Security groups for RMQ nodes"
  type        = "list"
  default     = []
}

variable "instance_type" {
  default = "t2.medium"
}

variable "ssh_key_name" {}

variable "ssl_certificate_arn" {}

variable "tags" {
  default = {}
}
