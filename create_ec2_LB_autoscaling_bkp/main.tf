provider "aws" {
  region = "eu-central-1"
}

module "my_vpc" {
  source = "../modules/vpc"
# vpc_cidr = "172.31.0.0/16"
  tenancy = "default"
  vpc_id = "${module.my_vpc.vpc_id}"
#  subnet_cidr = "172.31.1.0/24"
}

module "my_ec2" {
  source = "../modules/ec2"
  ec2_count = "3"
  subnet_id = ""
#  subnet_id = "${module.my_vpc.random_shuffle.sub_id.id}"
#  subnet_id = "${module.my_vpc.subnet_id}"
#  subnet_id = "${ tolist(data.aws_subnet_ids.all.ids)[ count.index % length( data.aws_subnet_ids.all.ids) ]}"
}

module "my_elb" {
  source = "../modules/LoadBalancer"
}
