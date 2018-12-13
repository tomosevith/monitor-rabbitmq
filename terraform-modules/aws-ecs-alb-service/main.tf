data "template_file" "task_definition" {
  template = "${var.task_template}"

  vars {
    name           = "${var.name}"
    image_url      = "${var.image_url}"
    service_name   = "${var.service_name}"
    service_port   = "${var.service_port}"
    memory         = "${var.service_memory}"
    cpu            = "${var.service_cpu}"
    fqdn           = "${var.fqdn}"
    region         = "${var.region}"
    log_group_name = "${var.log_group_name}"
    environment    = "${var.environment}"
    command        = "${jsonencode(split(",", var.service_cmd))}"
    entrypoint     = "${jsonencode(split(",", var.service_entrypoint))}"
    kms_key_alias  = "${var.kms_key_alias}"
  }
}

resource "aws_ecs_task_definition" "td" {
  family                = "${var.service_name}"
  container_definitions = "${data.template_file.task_definition.rendered}"
  task_role_arn         = "${var.task_role_arn}"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.service_name}"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.td.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"

  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 180

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.service_port}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_count", "task_definition"]
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
  ]
}

/*
resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_high" {
  alarm_name          = "${var.service_name}-high-cpu-${var.alarm_cpu_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.alarm_cpu_threshold}"
  unit                = "Percent"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.service_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_memory_high" {
  alarm_name          = "${var.service_name}-high-memory-${var.alarm_memory_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.alarm_memory_threshold}"
  unit                = "Percent"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.service_name}"
  }
}
*/

