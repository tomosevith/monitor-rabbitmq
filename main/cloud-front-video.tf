module "video" {
  source = "../terraform-modules/aws-cloudfront"

  name                    = "video-${local.name}"
  certificate_arn         = "${var.cf_ssl_certificate_arn}"
  bucket_name             = "${local.name}-video"
  log_include_cookies     = "false"
  log_bucket              = "${local.name}-logs"
  allowed_origins         = ["${var.allowed_origins}"]
  cloudfront_uploader_arn = ["${var.cloudfront_uploader_arn}", "${module.web_front_ssm_role.role_arn}"]
  domains                 = ["${var.domain_content}"]

  #allowed_methods = ["GET", "HEAD"]

  tags = {
    Name        = "${local.name}"
    Environment = "${terraform.env}"
  }
}
