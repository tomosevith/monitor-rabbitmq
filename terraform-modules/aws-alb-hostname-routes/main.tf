resource "aws_alb_listener_rule" "http" {
  count        = "${length(var.service_hosts)}"
  listener_arn = "${var.http_listener_arn}"
  priority     = "${var.priority + count.index + 1}"

  action {
    type             = "forward"
    target_group_arn = "${var.target_group_arn}"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.service_hosts, count.index)}"]
  }
}

resource "aws_alb_listener_rule" "https" {
  count        = "${length(var.service_hosts)}"
  listener_arn = "${var.https_listener_arn}"
  priority     = "${var.priority + count.index + 1}"

  action {
    type             = "forward"
    target_group_arn = "${var.target_group_arn}"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.service_hosts, count.index)}"]
  }
}
