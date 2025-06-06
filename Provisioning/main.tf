terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "selected" {
  id = "vpc-08cc38564a3b05e60"
}

resource "aws_key_pair" "deployer" {
  key_name   = "tf.pub"
  public_key = var.pub_key
}

resource "aws_security_group" "allow_tcp" {
  name        = "allow_tcp"
  description = "Allow Tcp inbound traffic and all outbound traffic"
  vpc_id      = "vpc-08cc38564a3b05e60"

    ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4" {
  security_group_id = aws_security_group.allow_tcp.id
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
  ip_protocol       = "tcp"
  from_port         = 25565
  to_port           = 25565
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = "vpc-08cc38564a3b05e60"

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_instance" "app_server" {
  ami           = "ami-0e8c824f386e1de06"
  instance_type = "t4g.small"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_tcp.id]
  key_name               = "tf.pub"

  tags = {
    Name = var.instance_name
  }
}