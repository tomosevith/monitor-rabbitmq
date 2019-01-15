output "rabbitmq_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "rabbitmq_internal_dns_name" {
  value = "${aws_elb.elb_internal.dns_name}"
}

output "rabbitmq_zone_id" {
  value = "${aws_elb.elb.zone_id}"
}
