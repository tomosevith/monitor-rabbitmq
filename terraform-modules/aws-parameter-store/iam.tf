resource "aws_iam_role" "main" {
  name = "${var.name}-parameter-store"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": ["ecs-tasks.amazonaws.com"]
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "main" {
  name = "${var.name}-parameter-store"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region}:453706994751:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region}:453706994751:parameter/${var.name}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys",
        "kms:ListAliases",
        "kms:Describe*",
        "kms:Decrypt"
      ],
      "Resource": [
        "${aws_kms_key.main.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "main" {
  name       = "${var.name}-parameter-store"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn = "${aws_iam_policy.main.arn}"
}
