resource "aws_security_group" "alb_security_group" {
  name_prefix = "alb-${var.name}"
  description = "Allow 80 443 inbound traffic to ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "alb-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ecs_security_group" {
  name_prefix = "ecs-${var.name}"
  description = "Allow all inbound traffic to ECS from ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "ecs-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds_security_group" {
  name_prefix = "rds-${var.name}"
  description = "Allow 5432 inbound traffic to RDS from ECS"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = ["${aws_security_group.ecs_security_group.id}",
      "${aws_security_group.converters_security_group.id}",
    ]
  }

  tags {
    Name        = "rds-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rmq_elb_security_group" {
  name_prefix = "rmq-elb-${var.name}"
  description = "Allow inbound traffic to  ELB rabbitmq from ECS and converters"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"

    security_groups = ["${aws_security_group.ecs_security_group.id}",
      "${aws_security_group.converters_security_group.id}",
    ]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5672
    to_port     = 5672
    cidr_blocks = ["${var.allowed_ips}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["${var.allowed_ips}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "rmq-elb-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rmq_node_security_group" {
  name_prefix = "rmq-node-${var.name}"
  description = "Allow traffic to rmq node from ECS"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.rmq_elb_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "rmq-node-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ssh_security_group" {
  name_prefix = "ssh-${var.name}"
  description = "Allow all inbound traffic to ssh port from 92.245.100.114 for bastion instance"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ips}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "ssh-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "converters_security_group" {
  name_prefix = "converters-${var.name}"
  description = "Allow traffic to converters from ECS"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "converters-${var.name}"
    Environment = "${terraform.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
