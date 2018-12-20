module "security_groups" {
  source      = "../terraform-modules/aws-security-group"
  vpc_id      = "${module.vpc.vpc_id}"
  allowed_ips = "${concat(var.allowed_ips, formatlist("%v/32", module.vpc.nat_public_ips))}"

  name = "${local.name}"
}
