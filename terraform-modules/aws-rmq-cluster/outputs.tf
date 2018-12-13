output "rabbitmq_endpoint" {
  value = "https://${aws_elb.elb.dns_name}"
}
