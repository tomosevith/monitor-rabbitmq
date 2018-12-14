resource "aws_ssm_parameter" "main" {
  count = "${var.count}"
  name  = "/${var.project_name}/${var.service_name}/${element(keys(var.parameters), count.index)}"
  value = "${element(values(var.parameters), count.index)}"
  type  = "String"

  //type      = "SecureString"
  //key_id    = "${var.kms_key_id}"
  overwrite = true

  tags = "${var.tags}"
}
