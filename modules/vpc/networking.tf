#resource "aws_vpc" "main" {
#  cidr_block = "${var.vpc_cidr}"
#  instance_tenancy = "${var.tenancy}"

#  tags = {
#    Name = "main"
#  }
#}

resource "aws_default_vpc" "default" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

#resource "random_shuffle" "az" {
#  input = [
#    for id in data.aws_availability_zones.available.names:
#    lower(id)
#  ]
#  result_count = 1
#}

#resource "aws_default_subnet" "default" {
#  count = "${length(data.aws_availability_zones.available.names)}"
#  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
#  availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
#}

#resource "aws_subnet" "default" {
#  cidr_block = "${aws_default_subnet.default[count.index].id}"
#  vpc_id = "${aws_default_vpc.default.id}"
#  count = "${length(data.aws_availability_zones.available.names)}"
#  availability_zone = data.aws_availability_zones.available.names[count.index]
#}

#resource "aws_subnet" "main" {
#  cidr_block = "${var.subnet_cidr}"
#  vpc_id = "${var.vpc_id}"
#}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

resource "random_shuffle" "sub_id" {
  input = [
    for id in data.aws_subnet_ids.all.ids:
    lower(id)
  ]
  result_count = 1
}

#data "aws_security_group" "default" {
#  vpc_id = data.aws_vpc.default.id
#  name   = "default"
#}

output "cidr_block" {
  value = aws_default_vpc.default.cidr_block
}

output "vpc_id" {
   value = aws_default_vpc.default.id
#   value = "${aws_vpc.main.id}"
}

output "subnet_id" {
#   value = aws_default_subnet.default.id
  value = random_shuffle.sub_id.result[0]
}
