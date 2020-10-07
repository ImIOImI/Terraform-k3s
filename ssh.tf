resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.ssh_key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "generated_key" {
  depends_on = [tls_private_key.key]
  content    = tls_private_key.key.private_key_pem
  filename   = local.ssh_key_path
}