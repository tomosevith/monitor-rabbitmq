provider "aws" {
  region = "${var.region}"
}

resource "random_string" "name" {
  length  = 6
  special = false
  upper   = false
}

locals {
  name = "${var.name}-${terraform.env}-${random_string.name.result}-${var.short_region}"
}
