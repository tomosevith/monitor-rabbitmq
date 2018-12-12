data "template_file" "aws_convert" {
  template = "${file("${path.module}/user-data/convert-instance.tpl")}"

  vars {
    name = "convert-${local.name}"
  }
}

resource "tls_private_key" "aws_convert" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_convert" {
  key_name   = "convert-${local.name}"
  public_key = "${tls_private_key.aws_convert.public_key_openssh}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_iam_instance_profile" "convert_instance" {
  name = "${var.name}"
  role = "${aws_iam_role.convert_instance.name}"
}
resource "aws_iam_role" "ecs_instance" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

# It may be useful to add the following for troubleshooting the InstanceStatus
# Health check if using the fitnesskeeper/consul docker image
# "ec2:Describe*",
# "autoscaling:Describe*",

resource "aws_iam_policy" "ecs_instance" {
  name        = "${var.name}"
  description = "A terraform created policy for ECS Instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:*",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "attach_ecs" {
  name       = "${var.name}"
  roles      = ["${aws_iam_role.ecs_instance.name}"]
  policy_arn = "${aws_iam_policy.ecs_instance.arn}"
}


resource "aws_launch_configuration" "converts" {
  security_group_id = "${module.security_groups.converters_id}"

  key_name                    = "${aws_key_pair.aws_convert.key_name}"
  name_prefix                 = "${var.aws_asg_name}"
  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.converts_instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.amazon_linux.name}"
  associate_public_ip_address = false
  ebs_optimized               = false
  user_data                   = "${data.template_file.aws_convert.rendered}"

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "converts" {
  name = "/converts/${var.name}"
}

resource "aws_autoscaling_group" "converts" {
  name                  = "${var.aws_asg_name}"
  vpc_zone_identifier   = ["${var.subnet_id}"]
  min_size              = "${var.asg_min}"
  max_size              = "${var.asg_max}"
  desired_capacity      = "${var.asg_desired}"
  launch_configuration  = "${aws_launch_configuration.converts.name}"
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
