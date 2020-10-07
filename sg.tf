resource "aws_security_group" "k3s_web" {
  name = "k3s-web"
  description = "Managed by Terraform"
  vpc_id = module.network_lookup.vpc-id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "k3s_kubectl" {
  name = "k3s-kubectl"
  description = "Managed by Terraform. Security group for just the k3s server."
  vpc_id = module.network_lookup.vpc-id

  ingress {
    description = "Kubectl ports for trusted ips and self"
    from_port = "6443"
    protocol = "tcp"
    to_port = "6443"
    cidr_blocks = local.safe_cidrs
    self = true
  }

  ingress {
    description = "Ping from anywhere"
    from_port = 8
    protocol = "icmp"
    to_port = 8
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "k3s_db" {
  name = "k3s-db"
  description = "Managed by Terraform"
  vpc_id = module.network_lookup.vpc-id

  ingress {
    description = "DB ports for trusted ips and self"
    from_port = local.db_port
    protocol = "tcp"
    to_port = local.db_port
    cidr_blocks = local.safe_cidrs
    self = true
  }

  ingress {
    description = "Ping from anywhere"
    from_port = 8
    protocol = "icmp"
    to_port = 8
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

output "sg_web" {
  value = aws_security_group.k3s_web.arn
}

output "sg_db" {
  value = aws_security_group.k3s_db.arn
}