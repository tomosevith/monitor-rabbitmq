data "aws_caller_identity" "current" {}

resource "aws_kms_key" "main" {
  description             = "Parameter store kms master key for ${var.service_name} ${var.environment} ${var.region}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags {
    "Environment" = "${var.environment}"
  }
}

resource "aws_kms_alias" "main_alias" {
  name          = "alias/${var.service_name}"
  target_key_id = "${aws_kms_key.main.id}"
}
