provider "aws" {
  region = "eu-central-1"
}

module "my_vpc" {
  source = "../modules/vpc"
  tenancy = "default"
  vpc_id = "${module.my_vpc.vpc_id}"
  vpc_name = "Default-VPC"
}

module "my_elb" {
  source = "../modules/LoadBalancer"
  ami_id = "ami-07dfba995513840b5"
  ec2_count = "2"
  elb_name = "elb-test"
  subnet_id = "${module.my_vpc.subnet_id}"
  vpc_id = "${module.my_vpc.vpc_id}"
  vpc_cidr = "${module.my_vpc.cidr_block}"
  enable_cross_zone_load_balancing = "true"
  key = "275387897436-Key-pair"
  instance_type = "t2.micro"
  elb_id = "${module.my_elb.elb_id}"
  elb-sg-id = "${module.my_elb.elb-sg-id}"
}

module "my_asg" {
  source = "../modules/autoscaling"
  asg_name = "my-ASG-terraform"
  image_id = "ami-07dfba995513840b5"
  instance_type = "t2.micro"
  key = "275387897436-Key-pair"
  device_name = "/dev/xvda"
  volume_size = "8"
  volume_type = "gp2"
  name_prefix = "my-launch-configuration-"
  max_size = "3"
  min_size = "2"
  elb_name = "elb-test"
  vpc_id = "${module.my_vpc.vpc_id}"
  vpc_cidr = "${module.my_vpc.cidr_block}"
  elb_id = "${module.my_elb.elb_id}"
  elb-sg-id = "${module.my_elb.elb-sg-id}"
  health_check_type = "ELB"
  policy_type = "TargetTrackingScaling"
  aspolicy_name = "instances_autoscaling_policy"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  scaling_adjustment = 1
  target_value = 90.0
}