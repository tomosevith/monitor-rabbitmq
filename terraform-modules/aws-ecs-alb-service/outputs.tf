output "target_group_arn" {
  value = "${aws_alb_target_group.alb_target.arn}"
}

output "task_definition_family" {
  value = "${aws_ecs_task_definition.td.family}"
}

output "task_definition_arn" {
  value = "${aws_ecs_task_definition.td.arn}"
}

output "service_name" {
  value = "${aws_ecs_service.ecs_service.name}"
}

output "service_role" {
  value = "${aws_ecs_service.ecs_service.iam_role}"
}
