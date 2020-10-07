#####
# DB
#####
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = local.db_name

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<accound id>:key/<kms key id>"
  name     = local.db_name
  username = local.db_user
  password = local.db_pass
  port     = local.db_port

  vpc_security_group_ids = [aws_security_group.k3s_db.id]

  maintenance_window = local.maintenance_window
  backup_window      = local.backup_window

  multi_az = true

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = local.tags

  enabled_cloudwatch_logs_exports = local.cloudwatch_exports

  # DB subnet group
  subnet_ids = module.network_lookup.public-subnet-ids

  # DB parameter group
  family = local.family

  # DB option group
  major_engine_version = local.major_engine_version

  # Snapshot name upon DB deletion
  final_snapshot_identifier = local.db_name

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
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

module "db-url" {
  source = "../../modules/route53/cname"
  domain = local.domain
  dns-name = local.db_url_prefix
  environment = local.environment
  dns-target = module.db.this_db_instance_address
}