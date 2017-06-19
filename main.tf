provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

resource "aws_key_pair" "consul" {
  key_name   = "${var.namespace}"
  public_key = "${file("${var.public_key_path}")}"
}

module "VPC" {
  source         = "./modules/VPC"
  namespace      = "${var.namespace}"
  cidr_blocks    = ["${var.cidr_blocks}"]
  vpc_cidr_block = "${var.vpc_cidr_block}"
}

module "IAM" {
  source    = "./modules/IAM"
  namespace = "${var.namespace}"
}

module "SecurityGroups" {
  source     = "./modules/SecurityGroups"
  consul_vpc = "${module.VPC.consul_vpc_id}"
  namespace  = "${var.namespace}"
  sg_cidr    = "${var.sg_cidr}"
}

module "Consul" {
  source                  = "./modules/Consul"
  consul_instance_profile = "${module.IAM.iam_instance_profile}"
  consul_securitygroup_id = "${module.SecurityGroups.consul_securitygroup_id}"
  consul_subnets          = "${module.VPC.consul_subnets}"
  consul_version          = "${var.consul_version}"
  consul_join_tag_key     = "${var.consul_join_tag_key}"
  consul_join_tag_value   = "${var.consul_join_tag_value}"
  cidr_blocks             = "${var.cidr_blocks}"
  vpc_cidr_block          = "${var.vpc_cidr_block}"
  namespace               = "${var.namespace}"
  key_name                = "${aws_key_pair.consul.id}"
  clients                 = "${var.clients}"
  servers                 = "${var.servers}"
}
