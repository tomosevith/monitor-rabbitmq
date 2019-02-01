data "aws_availability_zones" "available" {}

resource "null_resource" "subnets" {
  count = "${var.az_count}"

  triggers {
    # calculates private and public(offset 100) subnets and availability_zones by availability zone count
    private_subnets     = "${cidrsubnet("${var.cidr}", 8, count.index)}"
    database_subnets    = "${cidrsubnet("${var.cidr}", 8, count.index + 100)}"
    elasticache_subnets = "${cidrsubnet("${var.cidr}", 8, count.index + 150)}"
    public_subnets      = "${cidrsubnet("${var.cidr}", 8, count.index + 200)}"
    azs                 = "${data.aws_availability_zones.available.names[count.index]}"
  }
}

module "vpc" {
  source = "../terraform-modules/aws-vpc"

  name = "${local.name}"
  cidr = "${var.cidr}"

  azs                 = ["${null_resource.subnets.*.triggers.azs}"]
  private_subnets     = ["${null_resource.subnets.*.triggers.private_subnets}"]
  public_subnets      = ["${null_resource.subnets.*.triggers.public_subnets}"]
  database_subnets    = ["${null_resource.subnets.*.triggers.database_subnets}"]
  elasticache_subnets = ["${null_resource.subnets.*.triggers.elasticache_subnets}"]

  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${local.name}"
    Environment = "${terraform.env}"
  }
}
