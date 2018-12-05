resource "aws_route53_record" "web_backend" {
  name = "web-backend-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_alb.web_backend.dns_name}"
    zone_id                = "${aws_alb.web_backend.zone_id}"
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "web_front" {
  name = "web-front-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_alb.web_front.dns_name}"
    zone_id                = "${aws_alb.web_front.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "web_console" {
  name = "web-console-${terraform.env}.${var.domain}"

  zone_id = "${var.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_alb.web_console.dns_name}"
    zone_id                = "${aws_alb.web_console.zone_id}"
    evaluate_target_health = false
  }
}

#resource "aws_route53_record" "s3_video" {
#  name = "s3-video-${terraform.env}.${var.domain}"
#
#  zone_id = "${var.zone_id}"
#  type    = "A"
#
#  alias {
#    name                   = "${module.s3_video.cf_domain_name}"
#    zone_id                = "${module.s3_video.cf_hosted_zone_id}"
#    evaluate_target_health = false
#  }
#}