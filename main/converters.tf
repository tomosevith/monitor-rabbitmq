data "template_file" "aws_converters" {
  template = "${file("${path.module}/user-data/converters-instance.tpl")}"

  vars {
    name = "converters-${local.name}"
  }
}

resource "tls_private_key" "aws_converters" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_converters" {
  key_name   = "converters-${local.name}"
  public_key = "${tls_private_key.aws_converters.public_key_openssh}"
}

data "aws_ami" "converters_ami" {
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


resource "aws_launch_configuration" "converters" {
  security_groups             = ["${module.security_groups.converters_id}"]
  key_name                    = "${aws_key_pair.aws_converters.key_name}"
  name_prefix                 = "${var.aws_asg_name}"
  image_id                    = "${data.aws_ami.converters_ami.id}"
  instance_type               = "${var.converters_instance_type}"
  associate_public_ip_address = false
  ebs_optimized               = false
  user_data                   = "${data.template_file.aws_converters.rendered}"

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "converters" {
  name = "/converters/${var.name}"
}

resource "aws_autoscaling_group" "converters" {
  name                  = "converters-${local.name}"
  vpc_zone_identifier   = ["${module.vpc.private_subnets}"]
  min_size              = "${var.converters_asg_min}"
  max_size              = "${var.converters_asg_max}"
  desired_capacity      = "${var.converters_asg_desired}"
  launch_configuration  = "${aws_launch_configuration.converters.name}"
  termination_policies  = ["OldestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour"]
  protect_from_scale_in = false

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_count", "desired_capacity"]
  }

  tag {
    key                 = "Environment"
    value               = "${terraform.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "converters-${local.name}"
    propagate_at_launch = true
  }
}
