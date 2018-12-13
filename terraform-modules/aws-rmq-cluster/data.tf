data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2017*-gp2"]
  }
}

data "template_file" "cloud-init" {
  template = "${file("${path.module}/cloud-init.yaml")}"

  vars {
    sync_node_count = 3
    region          = "${var.region}"
    secret_cookie   = "${random_string.rmq_cookie.result}"
    admin_password  = "${var.rmq_admin_password}"
    rabbit_password = "${var.rmq_password}"
    message_timeout = "${3 * 24 * 60 * 60 * 1000}"         # 3 days
  }
}

data "template_cloudinit_config" "cloud-init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.cloud-init.rendered}"
  }
}

resource "random_string" "rmq_cookie" {
  length  = 32
  special = false
  upper   = true

  override_special = "!%&-_"
}
