# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = "us-west-2"
  shared_credentials_files = ["/Users/adeze/.aws/credentials"]

  default_tags {
    tags = {
      hashicorp-learn = "module-use"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = var.vpc_name
  cidr = var.vpc_cidr
  

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"
  count   = 2

  name = "my-ec2-instance"

  # ami                    = "ami-0c5204531f799e0c6" #ubuntu
  ami                    = "ami-097bd6037de54b1dc"  #rhel
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = "sonar"
  user_data              = <<EOF
#!/bin/bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade
# Add required dependencies for the jenkins package
sudo dnf install java-11-openjdk
sudo dnf install jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}



# module "iam_account" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-account"

#   account_alias = "awesome-company"

#   minimum_password_length = 37
#   require_numbers         = false
# }
# module "iam_user" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-user"

#   name          = "vasya.pupkin"
#   force_destroy = true

#   pgp_key = "keybase:test"

#   password_reset_required = false
# }