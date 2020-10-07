locals {
  domain = module.global.domain
  environment = module.global.environment
  iam_role_id = module.global.iam-role-webserver-id
  safe_cidrs = module.global.safe-cidrs
  
  #K3S Stuff
  k3s_agent_name = "k3s-agent"
  k3s_server_name = "k3s-server"
  
  k3s_datastore = "${local.engine}://${local.db_user}:${local.db_pass}@tcp(${local.db_url_prefix}.${local.domain}:${local.db_port})/${local.db_name}"

  server_cloud_init = "./config/server-cloud-init.yaml"
  agent_cloud_init = "./config/agent-cloud-init.yaml"
  
  #Generated SSH Key Name and Path
  ssh_key_name = "k3s-SSH-Key"
  ssh_key_path = "./rendered/${local.ssh_key_name}.pem"
  
  ssl_certificate_id = var.ssl_cert_arn
  instance_size = "t3.medium"
  
  #Agent ASG Options
  asg_min = "3"
  asg_max = "3"
  asg_desired = "3"

  #Mysql Options
  engine                = "mysql"
  engine_version        = "5.7.19"
  family                = "mysql5.7"
  major_engine_version  = "5.7"
  instance_class        = "db.t2.small"
  allocated_storage     = 16
  identifier            = "k3s-mysql"
  user                  = "appian"
  delete_protection     = true
  maintenance_window    = "Sat:00:00-Sat:03:00"
  backup_window         = "03:00-06:00"
  cloudwatch_exports    = ["audit", "general"]
  url_prefix            = "k3s-mysql"

  db_name       = "k3s"
  db_user       = "appuser"
  db_pass       = var.mysql_pass
  db_port       = "3306"
  db_url_prefix = "k3s-${local.engine}"
  #/END Mysql Options

  tags = {
    Application = "DevOps"
    Tier = "Utility"
    Environment = local.environment
    Terraform = true
    Name = "Rancher"
    Client = "default"
    k3s = true
  }
}

output "k3s_datastore" {
  value = local.k3s_datastore
}