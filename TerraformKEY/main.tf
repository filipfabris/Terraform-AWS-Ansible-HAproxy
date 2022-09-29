provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = var.region
}

#Create AWS key-pair if you do not have it already
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "verso_key.pem"
    file_permission = "0400"
}

resource "local_file" "public_key" {
    content  = tls_private_key.rsa.public_key_openssh
    filename = "verso_key.pub"
}

resource "aws_key_pair" "key" {
  key_name   = "verso_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

#Later use key_name = aws_key_pair.key.key_name
