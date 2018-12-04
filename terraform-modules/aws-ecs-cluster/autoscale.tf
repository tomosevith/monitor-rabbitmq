/*
resource "aws_autoscaling_policy" "up" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"
  cooldown               = 120
  name                   = "${aws_ecs_cluster.main.name}_asg_up"
  scaling_adjustment     = 1

  depends_on = [
    "aws_autoscaling_group.ecs",
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_memory_high" {
  alarm_name          = "${aws_ecs_cluster.main.name}-high-memory-${var.alarm_memory_threshold_high}"
  alarm_actions       = ["${aws_autoscaling_policy.up.arn}"]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${var.alarm_memory_threshold_high}"
  unit                = "Percent"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_autoscaling_policy" "down" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"
  cooldown               = 120
  name                   = "${aws_ecs_cluster.main.name}_asg_down"
  scaling_adjustment     = -1

  depends_on = [
    "aws_autoscaling_group.ecs",
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_memory_low" {
  alarm_name          = "${aws_ecs_cluster.main.name}-low-memory-${var.alarm_memory_threshold_low}"
  alarm_actions       = ["${aws_autoscaling_policy.down.arn}"]
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${var.alarm_memory_threshold_low}"
  unit                = "Percent"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_asg_failed" {
  alarm_name          = "${aws_autoscaling_group.ecs.name}-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  unit                = "Count"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs.name}"
  }
}
*/

