module "web_backend" {
  source = "../terraform-modules/aws-ecs-alb-service"

  region               = "${var.region}"
  environment          = "${terraform.env}"
  name                 = "${var.name}"
  service_name         = "backend-${local.name}"
  service_port         = "80"
  service_memory       = 300
  desired_count        = 1
  service_check_path   = "/"
  service_response     = "200"
  service_cmd          = "dotnet,VideoBattle.Back.Web.dll"
  service_entrypoint   = ""
  cluster_id           = "${module.ecs_cluster.cluster_id}"
  cluster_name         = "${module.ecs_cluster.cluster_name}"
  task_template        = "${file("${path.module}/task-definitions/task-defenition.json")}"
  image_url            = "${var.web_backend_image}"
  fqdn                 = "backend-${terraform.env}.${var.domain}"
  log_group_name       = "${module.ecs_cluster.log_group_name}"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 60

  kms_key_alias = "backend-${local.name}"
  task_role_arn = "${module.web_backend_ssm_role.role_arn}"
}

module "web_backend_ssm_role" {
  source = "../terraform-modules/aws-parameter-store"

  service_name = "backend-${local.name}"
  project_name = "${var.name}"
  environment  = "${terraform.workspace}"
  region       = "${var.region}"
}

module "web_backend_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "backend-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.web_backend_ssm_role.kms_key_id}"
  count        = 10

  parameters = {
    "ConnectionStrings/DefaultConnection" = "Host=${module.rds.this_db_instance_address};Database=${local.database_name};Username=${local.database_user};Password=${local.database_password}"
    "Auth/Jwt/SigningKey"                 = "${var.back_jwt_key}"
    "Cdn/UrlScheme/AwsRsaKeyId"           = "${var.cloudfront_key_id}"
    "RabbitMq/Username"                   = "rabbit"
    "RabbitMq/Password"                   = "${random_string.rmq_password.result}"
    "RabbitMq/VirtualHost"                = "/"
    "RabbitMq/Port"                       = "5672"
    "RabbitMq/Hostname"                   = "${module.rmq.rabbitmq_dns_name}"
    "AWS/BucketName"                      = "${module.video.s3_bucket_id}"
    "Cdn/BaseUrl"                         = "https://${var.domain_content}"

    #cdn_sl_key       = ""
    #minio_secret_key = ""
    #s3_bucket        = ""
  }

  tags = {
    Name        = "backend-${local.name}"
    Environment = "${terraform.env}"
  }
}

module "web_backend_additional_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "backend-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.web_backend_ssm_role.kms_key_id}"
  count        = "${length(var.additional_parameters)}"

  parameters = "${var.additional_parameters}"

  tags = {
    Name        = "backend-${local.name}"
    Environment = "${terraform.env}"
  }
}
