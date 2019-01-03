provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

resource "random_string" "name" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "database_prefix" {
  length  = 1
  special = false
  upper   = false
  number  = false
}

resource "random_string" "database_name" {
  length  = 20
  special = false
  upper   = false
}

resource "random_string" "database_user" {
  length  = 20
  special = false
  upper   = false
}

resource "random_string" "database_password" {
  length  = 32
  special = false
  upper   = true
}

resource "random_string" "app_key" {
  length  = 32
  special = false
  upper   = true
}

resource "random_string" "molodejj_tv" {
  length  = 32
  special = false
  upper   = true
}

resource "random_id" "front_jwt_key" {
  byte_length = 16
}

resource "random_id" "back_jwt_key" {
  byte_length = 16
}

resource "random_string" "console_jwt_key" {
  length  = 32
  special = false
  upper   = true
}

locals {
  name              = "${var.name}-${terraform.env}-${random_string.name.result}-${var.short_region}"
  database_name     = "${random_string.database_prefix.result}${random_string.database_name.result}"
  database_user     = "${random_string.database_prefix.result}${random_string.database_user.result}"
  database_password = "${random_string.database_password.result}"
  front_jwt_key     = "${random_id.front_jwt_key.hex}"
  back_jwt_key      = "${random_id.back_jwt_key.hex}"
  console_jwt_key   = "${random_string.console_jwt_key.result}"
}
