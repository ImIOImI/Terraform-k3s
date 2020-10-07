##################
# AGENT CONFIGS
##################
module "agents" {
  #we want to give the server a head start
  depends_on = [module.server]
  
  source = "./compute"
  #important stuff
  name = local.k3s_agent_name
  max = local.asg_max
  min = local.asg_min
  desired = local.asg_desired
  server_security_groups = [aws_security_group.k3s_web.id, aws_security_group.k3s_db.id]
  tags = merge(local.tags, {k3-agent = true})

  #defaults
  ami = data.aws_ami.ubuntu.id
  cloud-init = data.template_file.agent-cloud-init.rendered
  domain = local.domain
  elb_security_groups = [aws_security_group.k3s_web.id]
  environment = local.environment
  instance_size = local.instance_size
  ssh_key_name = aws_key_pair.generated_key.key_name
  ssl_cert = local.ssl_certificate_id
  subnet_ids =  module.network_lookup.public-subnet-ids
  iam_role = local.iam_role_id
}

data "template_file" "agent-cloud-init" {
  template = file("./config/cloud-init.yaml")

  vars = {
    private-ssh-key = indent(6, tls_private_key.key.private_key_pem)
    role            = "agent"
    server_name_tag = local.k3s_server_name
    data_con        = local.k3s_datastore
    server_asg      = local.k3s_server_name
  }
}

resource "local_file" "agent-cloud-init" {
  depends_on = [data.template_file.agent-cloud-init]
  content    = data.template_file.agent-cloud-init.rendered
  filename   = "./rendered/agent-cloud-init.yaml"
}

##################
# SEVER CONFIGS
##################
module "server" {
  source = "./compute"
  #important stuff
  depends_on = [module.db]
  name = local.k3s_server_name
  max = 1
  min = 1
  desired = 1
  server_security_groups = [aws_security_group.k3s_web.id, aws_security_group.k3s_db.id, aws_security_group.k3s_kubectl.id]
  tags = merge(local.tags, {k3-server = true})

  #defaults
  ami = data.aws_ami.ubuntu.id
  cloud-init = data.template_file.server-cloud-init.rendered
  domain = local.domain
  elb_security_groups = [aws_security_group.k3s_web.id]
  environment = local.environment
  instance_size = local.instance_size
  ssh_key_name = aws_key_pair.generated_key.key_name
  ssl_cert = local.ssl_certificate_id
  subnet_ids =  module.network_lookup.public-subnet-ids
  iam_role = local.iam_role_id
}

data "template_file" "server-cloud-init" {
  template = file("./config/cloud-init.yaml")

  vars = {
    private-ssh-key = indent(6, tls_private_key.key.private_key_pem)
    role            = "server"
    server_name_tag = local.k3s_server_name 
    data_con        = local.k3s_datastore
    server_ip       = "$(hostname -I)"
  }
}

resource "local_file" "server-cloud-init" {
  depends_on = [data.template_file.server-cloud-init]
  content    = data.template_file.server-cloud-init.rendered
  filename   = "./rendered/server-cloud-init.yaml"
}