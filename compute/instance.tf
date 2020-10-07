##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################

locals {
  cloud-init-md5 = md5(var.cloud-init)
}

################################################
# Launch configuration and autoscaling group
################################################
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = var.name

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "${var.name}-lc-${local.cloud-init-md5}"

  image_id        = var.ami
  instance_type   = var.instance_size
  security_groups = var.server_security_groups
  load_balancers  = [module.elb.this_elb_id]
  user_data       = var.cloud-init
  associate_public_ip_address = true
  key_name        = var.ssh_key_name

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = var.name
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  min_size                  = var.max
  max_size                  = var.min
  desired_capacity          = var.desired
  wait_for_capacity_timeout = 0

  iam_instance_profile = var.iam_role

  tags = [for k,v in merge(var.tags, {Name = var.name}) : {key = k, value = v, propagate_at_launch = true}]
}

######
# ELB
######
module "elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "${var.name}-elb"

  subnets         = var.subnet_ids
  security_groups = var.elb_security_groups
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = "80"
      instance_protocol = "http"
      lb_port           = "443"
      lb_protocol       = "https"
      ssl_certificate_id = var.ssl_cert
    },
    {
      instance_port     = "22"
      instance_protocol = "tcp"
      lb_port           = "22"
      lb_protocol       = "tcp"
    },
    {
      instance_port     = "6443"
      instance_protocol = "tcp"
      lb_port           = "6443"
      lb_protocol       = "tcp"
    },    
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = merge(var.tags, {Name = "${var.name}-elb"})
}

######
# R53
######
data "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "k3s_url" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.name
  type    = "A"
  alias {
    evaluate_target_health = false
    name = module.elb.this_elb_dns_name
    zone_id = module.elb.this_elb_zone_id
  }
}

output "asg" {
  value = module.asg
}

output "elb_dns_name" {
  value = module.elb.this_elb_dns_name
}

output "url" {
  value = "${var.name}.${var.domain}"
}