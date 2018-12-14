output "console_url" {
  value = "https://${aws_route53_record.web_console.fqdn}"
}

output "content_url" {
  value = "https://${aws_route53_record.content.fqdn}"
}

output "backend_url" {
  value = "https://${aws_route53_record.web_backend.fqdn}"
}

output "frontend_url" {
  value = "https://${aws_route53_record.web_front.fqdn}"
}

output "rabbitmq_url" {
  value = "https://${aws_route53_record.rabbitmq.fqdn}"
}
