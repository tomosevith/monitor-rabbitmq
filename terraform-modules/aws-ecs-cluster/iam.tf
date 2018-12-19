resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.name}"
  role = "${aws_iam_role.ecs_instance.name}"
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
        "s3:*",
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
