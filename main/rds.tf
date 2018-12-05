module "rds" {
  source = "..//terraform-modules/aws-rds"

  identifier = "${local.name}"

  engine            = "${var.rds_engine_type}"
  engine_version    = "${var.rds_engine_version}"
  instance_class    = "${var.rds_instance_class}"
  allocated_storage = "${var.rds_allocated_storage}"

  name                   = "${local.database_name}"
  username               = "${local.database_user}"
  password               = "${local.database_password}"
  port                   = "${var.rds_port}"
  multi_az               = "${var.rds_multi_az}"
  storage_encrypted      = "${var.rds_storage_encrypted}"
  vpc_security_group_ids = ["${module.security_groups.rds_id}"]

  maintenance_window = "Sun:00:00-Sun:03:00"
  backup_window      = "03:00-06:00"

  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  //monitoring_interval = "30"


  //monitoring_role_name   = "MyRDSMonitoringRole"
  //create_monitoring_role = true

  # DB subnet group
  subnet_ids = ["${module.vpc.database_subnets}"]
  # DB parameter group
  family = "postgresql9.6"
  # DB option group
  major_engine_version = "9.6"
  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${local.name}"
  # Database Deletion Protection
  deletion_protection = false
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    },
  ]
  tags = {
    Name        = "${local.name}"
    Environment = "${terraform.env}"
  }
}
