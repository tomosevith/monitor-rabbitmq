resource "tls_private_key" "aws_rmq" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_rmq" {
  key_name   = "rmq-${local.name}"
  public_key = "${tls_private_key.aws_rmq.public_key_openssh}"
}

resource "random_string" "rmq_admin_password" {
  length  = 20
  special = false
  upper   = true
}

resource "random_string" "rmq_password" {
  length  = 20
  special = false
  upper   = true

  override_special = "!%&-_"
}

module "rmq" {
  source = "..//terraform-modules/aws-rmq-cluster"

  name                    = "rmq-${local.name}"
  environment             = "${terraform.env}"
  region                  = "${var.region}"
  vpc_id                  = "${module.vpc.vpc_id}"
  private_subnets         = "${module.vpc.private_subnets}"
  public_subnets          = "${module.vpc.public_subnets}"
  cluster_security_groups = ["${module.security_groups.ssh_id}", "${module.security_groups.rmq_elb_id}"]
  node_security_groups    = ["${module.security_groups.rmq_node_id}"]
  instance_type           = "${var.rmq_instance_type}"
  ssh_key_name            = "${aws_key_pair.aws_rmq.key_name}"
  ssl_certificate_arn     = "${var.ssl_certificate_arn}"
  rmq_admin_password      = "${random_string.rmq_admin_password.result}"
  rmq_password            = "${random_string.rmq_password.result}"

  tags = {
    Name        = "${local.name}"
    Environment = "${terraform.env}"
  }
}
