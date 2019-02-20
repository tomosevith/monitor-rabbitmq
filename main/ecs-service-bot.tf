module "bot" {
  source = "../terraform-modules/aws-ecs-service"

  region               = "${var.region}"
  environment          = "${terraform.env}"
  name                 = "${var.name}"
  service_name         = "bot-${local.name}"
  service_memory       = 100
  desired_count        = 1
  min_capacity         = 1
  service_cmd          = "dotnet,VideoBattle.Bot.dll"
  service_entrypoint   = ""
  cluster_id           = "${module.ecs_cluster.cluster_id}"
  cluster_name         = "${module.ecs_cluster.cluster_name}"
  task_template        = "${file("${path.module}/task-definitions/task-defenition-bot.json")}"
  image_url            = "${var.bot_image}"
  fqdn                 = "bot-${terraform.env}.${var.domain}"
  log_group_name       = "${module.ecs_cluster.log_group_name}"
  vpc_id               = "${module.vpc.vpc_id}"

  kms_key_alias = "bot-${local.name}"
  task_role_arn = "${module.bot_ssm_role.role_arn}"
}

module "bot_ssm_role" {
  source = "../terraform-modules/aws-parameter-store"

  service_name = "bot-${local.name}"
  project_name = "${var.name}"
  environment  = "${terraform.workspace}"
  region       = "${var.region}"
}

module "bot_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "bot-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.bot_ssm_role.kms_key_id}"
  count        = 10

  parameters = {
    "ConnectionStrings/DefaultConnection" = "Host=${module.rds.this_db_instance_address};Database=${local.database_name};Username=${local.database_user};Password=${local.database_password}"
    "Auth/Jwt/SigningKey"                 = "${var.back_jwt_key}"
    "Cdn/UrlScheme/AwsRsaKeyId"           = "${var.cloudfront_key_id}"
    "RabbitMq/Username"                   = "rabbit"
    "RabbitMq/Password"                   = "${random_string.rmq_password.result}"
    "RabbitMq/VirtualHost"                = "/"
    "RabbitMq/Port"                       = "5672"
    "RabbitMq/Hostname"                   = "${module.rmq.rabbitmq_internal_dns_name}"
    "AWS/BucketName"                      = "${module.video.s3_bucket_id}"
    "Cdn/BaseUrl"                         = "https://${var.domain_content}"
  }

  tags = {
    Name        = "bot-${local.name}"
    Environment = "${terraform.env}"
  }
}

module "bot_additional_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "bot-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.bot_ssm_role.kms_key_id}"
  count        = "${length(var.additional_parameters)}"

  parameters = "${var.additional_parameters}"

  tags = {
    Name        = "bot-${local.name}"
    Environment = "${terraform.env}"
  }
}
