resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_high" {
  alarm_name          = "${var.service_name}-cpu-high-${var.alarm_cpu_threshold_high}"
  alarm_actions       = ["${aws_appautoscaling_policy.ecs_service_up.arn}"]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.alarm_cpu_threshold_high}"
  unit                = "Percent"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.service_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_low" {
  alarm_name          = "${var.service_name}-cpu-low-${var.alarm_cpu_threshold_low}"
  alarm_actions       = ["${aws_appautoscaling_policy.ecs_service_down.arn}"]
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.alarm_cpu_threshold_low}"
  unit                = "Percent"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.service_name}"
  }
}

resource "aws_appautoscaling_target" "ecs_service_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  //role_arn = "${aws_iam_role.ecs_service_autoscale.arn}"
  min_capacity = "${var.min_capacity}"
  max_capacity = "${var.max_capacity}"

  depends_on = [
    "aws_ecs_service.ecs_service",
  ]
}

resource "aws_appautoscaling_policy" "ecs_service_up" {
  name               = "${var.service_name}-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.ecs_service_scale_target",
  ]
}

resource "aws_appautoscaling_policy" "ecs_service_down" {
  name               = "${var.service_name}-scale-down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.ecs_service_scale_target",
  ]
}
