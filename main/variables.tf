variable "region" {
  default = "eu-central-1"
}

variable "short_region" {
  default = "ec1"
}

variable "az_count" {
  default = 2
}

variable "name" {
  default = "vb"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "ecs_instance_type" {
  default = "t2.small"
}

variable "ecs_asg_min" {
  default = 1
}

variable "ecs_asg_max" {
  default = 1
}

variable "ecs_asg_desired" {
  default = 1
}

####### variable fot ecs cluster services 

variable "web_front_image" {
  default = "videobattle.front.web"
}

variable "web_front_additional_parameters" {
  default = {}
}

variable "web_backend_image" {
  default = "videobattle.backend.web"
}

variable "web_backend_additional_parameters" {
  default = {}
}

variable "web_console_image" {
  default = "videobattle.console"
}

variable "web_console_additional_parameters" {
  default = {}
}

##### RDS INSTANCE
variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t2.small"
}

variable "rds_engine_version" {
  description = "The engine version to use"
  default     = "9.6.10"
}

variable "rds_engine_type" {
  description = "The database engine to use"
  default     = "postgres"
}

variable "rds_port" {
  description = "The database engine to use"
  default     = "5432"
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = 7
}

variable "rds_allocated_storage" {
  description = "The days to retain backups for"
  default     = 10
}

variable "rds_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "rds_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  default     = false
}

variable "domain" {
  default = "beta.playandplay.ru"
}

variable "domain_content" {
  default = "content.playandplay.ru"
}

### Bastion Host
variable "enable_bastion" {
  default = "false"
}

##### CLOUDFORMATION VIDEO

variable "cf_ssl_certificate_arn" {
  default = "arn:aws:acm:eu-central-1:132867155609:certificate/632af947-175e-4725-8bd9-a49ed2a01553"
}

variable "allowed_origins" {
  default = ["*.content.playandplay.ru", "https://content.playandplay.ru"]
}

variable "cloudfront_uploader_arn" {
  default = "arn:aws:iam::132867155609:user/gitlab-ci"
}