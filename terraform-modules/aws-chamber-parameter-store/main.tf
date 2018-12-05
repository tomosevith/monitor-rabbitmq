resource "aws_ssm_parameter" "main" {
  count     = "${var.count}"
  name      = "/${var.name}/${element(keys(var.parameters), count.index)}"
  value     = "${element(values(var.parameters), count.index)}"
  type      = "SecureString"
  key_id    = "${var.kms_key_id}"
  overwrite = true

  tags = "${var.tags}"
}
