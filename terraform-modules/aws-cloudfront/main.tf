# --- S3 bucket ---

data "aws_iam_policy_document" "s3_policy_cf_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${var.cloudfront_uploader_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = ["${var.cloudfront_uploader_arn}"]
    }
  }
}

//resource "aws_s3_bucket_policy" "bucket" {
//  bucket = "${aws_s3_bucket.bucket.id}"
//  policy = "${data.aws_iam_policy_document.s3_policy_cf_bucket.json}"
//}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}"
  acl           = "private"
  policy        = "${data.aws_iam_policy_document.s3_policy_cf_bucket.json}"
  force_destroy = true

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["DELETE", "GET", "HEAD", "POST", "PUT"]
    allowed_origins = ["${var.allowed_origins}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  tags = "${merge("${var.tags}", map("Name", format("%s-bucket", var.name)))}"
}

# --- CloudFront ---

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.name}"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.log_bucket}"

  #policy = "${data.aws_iam_policy_document.s3_policy_cf_logs.json}"
  force_destroy = true

  tags = "${merge(var.tags, map("Name", format("%s", var.log_bucket)))}"
}

resource "aws_cloudfront_distribution" "cf" {
  enabled             = "true"
  is_ipv6_enabled     = "${var.ipv6_enabled}"
  comment             = "${var.comment}"
  default_root_object = "index.html"
  price_class         = "${var.price_class}"

  logging_config = {
    include_cookies = "${var.log_include_cookies}"
    bucket          = "${var.log_bucket}.s3.amazonaws.com"
    prefix          = "${var.log_prefix}"
  }

  aliases = ["${var.domains}"]

  origin {
    domain_name = "${aws_s3_bucket.bucket.bucket_domain_name}"
    origin_id   = "${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  default_cache_behavior {
    allowed_methods  = "${var.allowed_methods}"
    cached_methods   = "${var.cached_methods}"
    target_origin_id = "${var.bucket_name}"
    compress         = "${var.compress}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    min_ttl                = "${var.min_ttl}"
    default_ttl            = "${var.default_ttl}"
    max_ttl                = "${var.max_ttl}"
  }

  ordered_cache_behavior {
    path_pattern     = "*.mp4"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    trusted_signers        = ["self"]
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  tags = "${merge("${var.tags}", map("Name", format("%s", var.name)))}"

  depends_on = ["aws_s3_bucket.log_bucket"]
}
