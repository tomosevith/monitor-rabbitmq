resource "aws_route53_record" "web_backend" {
  name = "backend-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "web_front" {
  name = "front-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "web_console" {
  name = "console-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "content" {
  name = "content-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${module.video.cf_domain_name}"
    zone_id                = "${module.video.cf_hosted_zone_id}"
    evaluate_target_health = false
  }
}
