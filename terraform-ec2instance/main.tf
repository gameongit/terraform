provider "aws" {
   version = "~> 2.15"
   region = "${var.aws_region}"
   assume_role {
   role_arn = "${var.aws_role}"
   }
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "default" {
  vpc_id = "${aws_vpc.default.id}"
  name = "assignement-securitygroup"
  description = "Security group for instances"

  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
 }

  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["10.0.0.0/16"]
 }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
 }

}

resource "aws_instance" "web" {
  count  =  1
  instance_type  = "t2.micro"
#  ami   = "ami-090f10efc254eaf55"
  ami   = "${var.aws_ami["redhat8"]}"
  key_name = "mynodes"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

# Same Subnet as of ELB.

  subnet_id = "${aws_subnet.default.id}"

# Running remote provisioner on instances to install nginx
  tags = {
    Name = "${var.aws_name}-${count.index}"
  }
user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install nginx -y
            sudo service nginx start
            EOF           
}

