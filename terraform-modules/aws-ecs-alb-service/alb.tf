resource "aws_alb_target_group" "alb_target" {
  #count = "${var.service_port ? 1 : 0}"
  name                 = "${var.service_name}"
  port                 = "${var.service_port}"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    healthy_threshold   = 2
    interval            = 60
    path                = "${var.service_check_path}"
    timeout             = 10
    unhealthy_threshold = 10
    matcher             = "${var.service_response}"
  }

  tags {
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
  }
}

/*
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name          = "${aws_alb_target_group.alb_target.name}-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "20"
  unit                = "Count"
  treat_missing_data  = "notBreaching"

  dimensions {
    TargetGroup  = "${aws_alb_target_group.alb_target.arn_suffix}"
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_target_unhealthy" {
  alarm_name          = "${aws_alb_target_group.alb_target.name}-unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  unit                = "Count"

  dimensions {
    TargetGroup  = "${aws_alb_target_group.alb_target.arn_suffix}"
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}

/*
resource "aws_cloudwatch_metric_alarm" "alb_target_responce_time" {
  alarm_name          = "${aws_alb_target_group.alb_target.name}-responce"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.7"
  unit                = "Seconds"
  treat_missing_data  = "notBreaching"

  dimensions {
    TargetGroup  = "${aws_alb_target_group.alb_target.arn_suffix}"
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}
*/

