resource "aws_launch_configuration" "rabbitmq" {
  name_prefix          = "${var.name}-"
  image_id             = "${data.aws_ami.ami.id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.ssh_key_name}"
  security_groups      = ["${var.node_security_groups}"]
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
  user_data            = "${data.template_file.cloud-init.rendered}"

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "rabbitmq" {
  name                      = "${var.name}"
  max_size                  = "${var.count}"
  min_size                  = "${var.count}"
  desired_capacity          = "${var.count}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.rabbitmq.name}"
  load_balancers            = ["${aws_elb.elb.name}", "${aws_elb.elb_internal.name}"]
  vpc_zone_identifier       = ["${var.private_subnets}"]

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }
}

resource "aws_elb" "elb" {
  name = "${var.name}"

  listener {
    instance_port     = 5672
    instance_protocol = "tcp"
    lb_port           = 5672
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  listener {
    instance_port      = 15672
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.ssl_certificate_arn}"
  }

  health_check {
    interval            = 30
    unhealthy_threshold = 10
    healthy_threshold   = 2
    timeout             = 3
    target              = "TCP:5672"
  }

  subnets         = ["${var.public_subnets}"]
  idle_timeout    = 3600
  internal        = false
  security_groups = ["${var.cluster_security_groups}"]

  tags = "${var.tags}"
}

resource "aws_elb" "elb_internal" {
  name = "${var.name}-internal"

  listener {
    instance_port     = 5672
    instance_protocol = "tcp"
    lb_port           = 5672
    lb_protocol       = "tcp"
  }

  health_check {
    interval            = 30
    unhealthy_threshold = 10
    healthy_threshold   = 2
    timeout             = 3
    target              = "TCP:5672"
  }

  subnets         = ["${var.private_subnets}"]
  idle_timeout    = 3600
  internal        = true
  connection_draining = true
  cross_zone_load_balancing = false
  security_groups = ["${var.cluster_security_groups}"]

  tags = "${var.tags}"
}
