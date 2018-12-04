resource "aws_ecs_cluster" "main" {
  name = "${var.name}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.name}"
}

resource "aws_autoscaling_group" "ecs" {
  name                  = "${var.aws_asg_name}"
  vpc_zone_identifier   = ["${var.subnet_id}"]
  min_size              = "${var.asg_min}"
  max_size              = "${var.asg_max}"
  desired_capacity      = "${var.asg_desired}"
  launch_configuration  = "${aws_launch_configuration.ecs.name}"
  termination_policies  = ["OldestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour"]
  protect_from_scale_in = "${var.protect_from_scale_in}"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_count", "desired_capacity"]
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.aws_asg_name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "ecs" {
  security_groups = ["${var.security_group_id}"]

  key_name                    = "${var.key_name}"
  name_prefix                 = "${var.aws_asg_name}"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance.name}"
  associate_public_ip_address = "${var.public_ip}"
  ebs_optimized               = "${var.ebs_optimized}"

  user_data = "${var.user_data}"

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdcz"
    volume_size           = "${var.docker_volume_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
