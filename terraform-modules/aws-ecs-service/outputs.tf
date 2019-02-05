output "task_definition_family" {
  value = "${aws_ecs_task_definition.td.family}"
}

output "task_definition_arn" {
  value = "${aws_ecs_task_definition.td.arn}"
}

output "service_name" {
  value = "${aws_ecs_service.ecs_service.name}"
}
