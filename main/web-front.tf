module "web_front" {
  source = "../terraform-modules/aws-ecs-alb-service"

  region               = "${var.region}"
  environment          = "${terraform.env}"
  name                 = "${var.name}"
  service_name         = "front-${local.name}"
  service_port         = "80"
  service_memory       = 480
  desired_count        = 1
  service_check_path   = "/"
  service_response     = "200"
  service_cmd          = "dotnet,VideoBattle.Front.Web.dll"
  service_entrypoint   = ""
  cluster_id           = "${module.ecs_cluster.cluster_id}"
  cluster_name         = "${module.ecs_cluster.cluster_name}"
  task_template        = "${file("${path.module}/task-definitions/task-defenition.json")}"
  image_url            = "${var.web_front_image}"
  fqdn                 = "front-${terraform.env}.${var.domain}"
  log_group_name       = "${module.ecs_cluster.log_group_name}"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 60

  kms_key_alias = "front-${local.name}"
  task_role_arn = "${module.web_front_ssm_role.role_arn}"
}

module "web_front_ssm_role" {
  source = "../terraform-modules/aws-parameter-store"

  service_name = "front-${local.name}"
  project_name = "${var.name}"
  environment  = "${terraform.workspace}"
  region       = "${var.region}"
}

module "web_front_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "front-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.web_front_ssm_role.kms_key_id}"
  count        = 10

  parameters = {
    "ConnectionStrings/DefaultConnection" = "Host=${module.rds.this_db_instance_address};Database=${local.database_name};Username=${local.database_user};Password=${local.database_password}"
    "Auth/Jwt/SigningKey"                 = "${local.front_jwt_key}"
    "RabbitMq/Username"                   = "rabbit"
    "RabbitMq/Password"                   = "${random_string.rmq_password.result}"
    "RabbitMq/VirtualHost"                = "/"
    "RabbitMq/Port"                       = "5672"
    "RabbitMq/Hostname"                   = "${aws_route53_record.rabbitmq.fqdn}"
    "UrlSchemes/Molodejj.Tv/Secret"       = "${random_string.molodejj_tv.result}"
    "Cdn/UrlScheme/AwsRsaKeyId"           = "${aws_cloudfront_public_key.signed_link.id}"
    "Cdn/UrlScheme/AwsRsaKey"             = "${tls_private_key.signed_link.private_key_pem}"

    #cdn_sl_key       = ""
    #minio_secret_key = ""
    #s3_bucket        = ""
  }

  tags = {
    Name        = "front-${local.name}"
    Environment = "${terraform.env}"
  }
}

module "web_front_additional_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "front-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.web_front_ssm_role.kms_key_id}"
  count        = "${length(var.web_front_additional_parameters)}"

  parameters = "${var.web_front_additional_parameters}"

  tags = {
    Name        = "front-${local.name}"
    Environment = "${terraform.env}"
  }
}
