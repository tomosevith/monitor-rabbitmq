data "template_file" "aws_ecs" {
  template = "${file("${path.module}/user-data/ecs-instance.tpl")}"

  vars {
    cluster_name = "${local.name}"
  }
}

resource "tls_private_key" "aws_ecs" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_ecs" {
  key_name   = "ecs-${local.name}"
  public_key = "${tls_private_key.aws_ecs.public_key_openssh}"
}

data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized*"]
  }
}

module "ecs_cluster" {
  source = "../terraform-modules/aws-ecs-cluster"

  name              = "${local.name}"
  environment       = "${terraform.env}"
  key_name          = "${aws_key_pair.aws_ecs.key_name}"
  ami_id            = "${data.aws_ami.ecs_ami.id}"
  instance_type     = "${var.ecs_instance_type}"
  asg_min           = "${var.ecs_asg_min}"
  asg_max           = "${var.ecs_asg_max}"
  asg_desired       = "${var.ecs_asg_desired}"
  public_ip         = false
  ebs_optimized     = false
  security_group_id = "${module.security_groups.ecs_id}"
  subnet_id         = "${module.vpc.public_subnets}"
  aws_asg_name      = "ecs-${local.name}"
  user_data         = "${data.template_file.aws_ecs.rendered}"
}
