resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion-${local.name}"
  public_key = "${tls_private_key.bastion.public_key_openssh}"
}

data "aws_ami" "bastion_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "bastion-${local.name}"
  vpc_zone_identifier  = ["${module.vpc.public_subnets}"]
  min_size             = "${var.enable_bastion == "true" ? 1 : 0}"
  max_size             = "${var.enable_bastion == "true" ? 1 : 0}"
  desired_capacity     = "${var.enable_bastion == "true" ? 1 : 0}"
  launch_configuration = "${aws_launch_configuration.bastion.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Environment"
    value               = "${terraform.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "bastion-${local.name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "bastion" {
  security_groups = ["${module.security_groups.ssh_id}"]

  key_name      = "${aws_key_pair.bastion.key_name}"
  name_prefix   = "bastion-${local.name}"
  image_id      = "${data.aws_ami.bastion_ami.id}"
  instance_type = "t2.nano"

  //iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance.name}"
  associate_public_ip_address = true
  ebs_optimized               = false

  //user_data = "${var.user_data}"

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
