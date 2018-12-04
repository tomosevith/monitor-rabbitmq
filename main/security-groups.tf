module "security_groups" {
  source = "../terraform-modules/aws-security-group"
  vpc_id = "${module.vpc.vpc_id}"

  name = "${local.name}"
}
