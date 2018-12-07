resource "aws_alb" "alb" {
  name = "${local.name}"

  #internal        = true
  security_groups = ["${module.security_groups.alb_id}"]
  subnets         = ["${module.vpc.public_subnets}"]

  tags {
    Name        = "${local.name}"
    Environment = "${terraform.env}"
  }
}

##### HTTP and HTTPS LISTENERS

resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.ssl_certificate_arn}"

  default_action {
    target_group_arn = "${module.web_front.target_group_arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${module.web_front.target_group_arn}"
    type             = "forward"
  }
}

##### RULES FOR ALB TO ROUTE TRAFFIC TO THE SERVICES BY HOSTNAMES

module "web_front_alb_routes" {
  source = "../terraform-modules/aws-alb-hostname-routes"

  priority           = 100
  http_listener_arn  = "${aws_alb_listener.alb_listener_http.arn}"
  https_listener_arn = "${aws_alb_listener.alb_listener_https.arn}"
  target_group_arn   = "${module.web_front.target_group_arn}"
  service_hosts      = ["front-${terraform.env}.${var.domain}", "front.${var.domain}", "${var.domain}"]
}

module "web_backend_alb_routes" {
  source = "../terraform-modules/aws-alb-hostname-routes"

  priority           = 60
  http_listener_arn  = "${aws_alb_listener.alb_listener_http.arn}"
  https_listener_arn = "${aws_alb_listener.alb_listener_https.arn}"
  target_group_arn   = "${module.web_backend.target_group_arn}"
  service_hosts      = ["backend-${terraform.env}.${var.domain}", "backend.${var.domain}"]
}


module "web_console_alb_routes" {
  source = "../terraform-modules/aws-alb-hostname-routes"

  priority           = 50
  http_listener_arn  = "${aws_alb_listener.alb_listener_http.arn}"
  https_listener_arn = "${aws_alb_listener.alb_listener_https.arn}"
  target_group_arn   = "${module.web_console.target_group_arn}"
  service_hosts      = ["console-${terraform.env}.${var.domain}", "console.${var.domain}"]
}
/*
resource "aws_cloudwatch_metric_alarm" "alb_request_count_low" {
  alarm_name          = "${aws_alb.alb.name}-request_count_low"
  alarm_actions       = ["${aws_sns_topic.alarm.arn}"]
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  unit                = "Count"

  dimensions {
    LoadBalancer = "${aws_alb.alb.arn_suffix}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_request_count_high" {
  alarm_name          = "${aws_alb.alb.name}-request_count_high"
  alarm_actions       = ["${aws_sns_topic.alarm.arn}"]  
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "100"
  unit                = "Count"

  dimensions {
    LoadBalancer = "${aws_alb.alb.arn_suffix}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_count_high" {
  alarm_name          = "${aws_alb.alb.name}-5xx_count_high"
  alarm_actions       = ["${aws_sns_topic.alarm.arn}"]  
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "20"
  unit                = "Count"
  treat_missing_data  = "notBreaching"

  dimensions {
    LoadBalancer = "${aws_alb.alb.arn_suffix}"
  }
}
*/

