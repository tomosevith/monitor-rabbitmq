output "alb_id" {
  value = ["${aws_security_group.alb_security_group.id}"]
}

output "ecs_id" {
  value = "${aws_security_group.ecs_security_group.id}"
}

output "rds_id" {
  value = "${aws_security_group.rds_security_group.id}"
}

output "rmq_elb_id" {
  value = "${aws_security_group.rmq_elb_security_group.id}"
}

output "rmq_node_id" {
  value = "${aws_security_group.rmq_node_security_group.id}"
}

output "converters_id" {
  value = "${aws_security_group.converters_security_group.id}"
}

output "ssh_id" {
  value = ["${aws_security_group.ssh_security_group.id}"]
}
