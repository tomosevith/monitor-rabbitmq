data "template_file" "aws_converters" {
  template = "${file("${path.module}/user-data/converters-instance.tpl")}"

  vars {
    name             = "converters-${local.name}"
    region           = "${var.region}"
    converters_image = "${var.converters_image}"
  }
}

module "converters_ssm_role" {
  source = "../terraform-modules/aws-parameter-store"

  name        = "converters-${local.name}"
  environment = "${terraform.workspace}"
  region      = "${var.region}"
}

module "converters_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "converterst-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.converters_ssm_role.kms_key_id}"
  count        = 14

  parameters = {
    "ConnectionStrings/DefaultConnection"       = "Host=${module.rds.this_db_instance_address};Database=${local.database_name};Username=${local.database_user};Password=${local.database_password}"
    "Auth/Jwt/SigningKey"                       = "${local.front_jwt_key}"
    "RabbitMq/Username"                         = "${local.rabbitmq_user}"
    "RabbitMq/Password"                         = "${local.rabbitmq_pwd}"
    "RabbitMq/VirtualHost"                      = "/"
    "RabbitMq/Port"                             = "5672"
    "RabbitMq/Hostname"                         = "${aws_route53_record.rabbitmq.fqdn}"
    "UrlSchemes/Molodejj.Tv/Secret"             = "${random_string.molodejj_tv.result}"
    "Cdn/UrlScheme/AwsRsaKeyId"                 = ""
    "Cdn/UrlScheme/AwsRsaKey"                   = ""
    "GooglePlay/ServiceAccountKey/private_key"  = ""
    "GoogleCloudMessaging/AuthToken"            = ""
    "ApplePushNotification/Certificate"         = ""
    "ApplePushNotification/CertificatePassword" = ""
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
  security_groups             = ["${module.security_groups.converters_id}", "${module.security_groups.ssh_id}"]
  key_name                    = "${aws_key_pair.aws_converters.key_name}"
  name_prefix                 = "converters-${local.name}"
  image_id                    = "${data.aws_ami.converters_ami.id}"
  instance_type               = "${var.converters_instance_type}"
  associate_public_ip_address = false
  ebs_optimized               = false
  user_data                   = "${data.template_file.aws_converters.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.converters_instance.name}"

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
  name = "/converters/${local.name}"
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

resource "aws_iam_instance_profile" "converters_instance" {
  name = "converters-${local.name}"
  role = "${aws_iam_role.converters_instance.name}"
}

resource "aws_iam_role" "converters_instance" {
  name = "converters-${local.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": ["ec2.amazonaws.com"]
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

resource "aws_iam_policy" "converters_instance" {
  name        = "converters-${local.name}"
  description = "A terraform created policy for EC2 Instances"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}

EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "attach_converters" {
  name       = "converters-${local.name}"
  roles      = ["${aws_iam_role.converters_instance.name}"]
  policy_arn = "${aws_iam_policy.converters_instance.arn}"
}
