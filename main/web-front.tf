module "web_front" {
  source = "../terraform-modules/aws-ecs-alb-service"

  region      = "${var.region}"
  environment = "${terraform.env}"

  service_name         = "web-front-${local.name}"
  service_port         = "80"
  service_memory       = 480
  desired_count        = 1
  service_check_path   = "/"
  service_response     = "200"
  service_cmd          = "./wait-for-it.sh,broker:5672,-s,-t,30,--,dotnet,VideoBattle.Front.Web.dll"
  service_entrypoint   = "/usr/local/bin/chamber,exec,web-front-${local.name},--"
  cluster_id           = "${module.ecs_cluster.cluster_id}"
  cluster_name         = "${module.ecs_cluster.cluster_name}"
  task_template        = "${file("${path.module}/task-definitions/task-defenition.json")}"
  image_url            = "${var.web_front_image}"
  fqdn                 = "web-front-${terraform.env}.${var.domain}"
  log_group_name       = "${module.ecs_cluster.log_group_name}"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 60

  kms_key_alias = "web-front-${local.name}"
  task_role_arn = "${module.web_front_ssm_role.role_arn}"
}

module "web_front_ssm_role" {
  source = "../terraform-modules/aws-parameter-store"

  name        = "web-front-${local.name}"
  environment = "${terraform.workspace}"
  region      = "${var.region}"
}

module "web_front_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  name       = "web-front-${local.name}"
  kms_key_id = "${module.web_front_ssm_role.kms_key_id}"
  count      = 11

  parameters = {
    db_host          = "${module.rds.this_db_instance_address}"
    db_database      = "${local.database_name}"
    db_username      = "${local.database_user}"
    db_password      = "${local.database_password}"
    app_key          = "${random_string.app_key.result}"
    front_jwt_key    = "${local.front_jwt_key}"
    rabbitmq_user    = "${local.rabbitmq_user}"
    rabbitmq_pwd     = "${local.rabbitmq_pwd}"
    cdn_sl_key       = ""
    minio_secret_key = ""
    s3_bucket        = "${module.minio_static.s3_bucket_id}"
  }

  tags = {
    Name        = "web-front-${local.name}"
    Environment = "${terraform.env}"
  }
}

module "web_front_additional_parameters" {
  source = "../terraform-modules/aws-chamber-parameter-store"

  name       = "web-front-${local.name}"
  kms_key_id = "${module.web_front_ssm_role.kms_key_id}"
  count      = "${length(var.web_front_additional_parameters)}"

  parameters = "${var.web_front_additional_parameters}"

  tags = {
    Name        = "web-front-${local.name}"
    Environment = "${terraform.env}"
  }
}