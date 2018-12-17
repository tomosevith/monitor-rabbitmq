module "web_console" {
  source = "../terraform-modules/aws-ecs-alb-service"

  region               = "${var.region}"
  environment          = "${terraform.env}"
  name                 = "${var.name}"
  service_name         = "console-${local.name}"
  service_port         = "80"
  service_memory       = 300
  desired_count        = 1
  service_check_path   = "/"
  service_response     = "200"
  service_cmd          = "dotnet,VideoBattle.Console.dll"
  service_entrypoint   = "/usr/local/bin/chamber,exec,console-${local.name},--"
  cluster_id           = "${module.ecs_cluster.cluster_id}"
  cluster_name         = "${module.ecs_cluster.cluster_name}"
  task_template        = "${file("${path.module}/task-definitions/task-defenition.json")}"
  image_url            = "${var.web_console_image}"
  fqdn                 = "console-${terraform.env}.${var.domain}"
  log_group_name       = "${module.ecs_cluster.log_group_name}"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 60

  kms_key_alias = "console-${local.name}"
  task_role_arn = "${module.web_console_ssm_role.role_arn}"
}

module "web_console_ssm_role" {
  source = "../terraform-modules/aws-parameter-store"

  name        = "console-${local.name}"
  environment = "${terraform.workspace}"
  region      = "${var.region}"
}

module "web_console_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "console-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.web_console_ssm_role.kms_key_id}"
  count        = 8

  parameters = {
    "ConnectionStrings/DefaultConnection"       = "Host=${module.rds.this_db_instance_address};Database=${local.database_name};Username=${local.database_user};Password=${local.database_password}"
    "UrlSchemes/Molodejj.Tv/Secret"             = "${random_string.molodejj_tv.result}"
    "Cdn/UrlScheme/AwsRsaKeyId"                 = "1"
    "Cdn/UrlScheme/AwsRsaKey"                   = "1"
    "GooglePlay/ServiceAccountKey/private_key"  = "1"
    "GoogleCloudMessaging/AuthToken"            = "1"
    "ApplePushNotification/Certificate"         = "1"
    "ApplePushNotification/CertificatePassword" = "1"

    #cdn_sl_key       = ""
    #minio_secret_key = ""
    #s3_bucket        = ""
  }

  tags = {
    Name        = "console-${local.name}"
    Environment = "${terraform.env}"
  }
}

module "web_console_additional_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  service_name = "console-${local.name}"
  project_name = "${var.name}"
  kms_key_id   = "${module.web_console_ssm_role.kms_key_id}"
  count        = "${length(var.web_console_additional_parameters)}"

  parameters = "${var.web_console_additional_parameters}"

  tags = {
    Name        = "console-${local.name}"
    Environment = "${terraform.env}"
  }
}
