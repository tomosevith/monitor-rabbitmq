output "role_arn" {
  value = "${aws_iam_role.main.arn}"
}

output "role_name" {
  value = "${aws_iam_role.main.name}"
}

output "kms_key_id" {
  value = "${aws_kms_key.main.id}"
}
