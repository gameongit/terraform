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

resource "aws_security_group" "lb" {
  vpc_id = "${aws_vpc.default.id}"
  name = "assignement-elb"
  description = "Security group for ELB"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
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

resource "aws_elb" "nginx" {
  name = "assignement-elb"

  subnets   = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.lb.id}"]
#  instances       = ["${aws_instance.web.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
 }

}

#
resource "aws_key_pair" "devops" {
  key_name   = "devops-key"
 # public_key = "${file("/root/terraform/id_rsa.pub")}"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqYenZH9RsbybDAdA4G7lZ9NC2izFZBBoyQmOjZituVgpmYRUiUrYv8FCE4hfrwL4QwmPa9sALpDovYiRD6k2d9366BYndZ0f6ft0bhOiNkQv5WIroWwQIE/zeaeAru4g0Bp6UW3hX0DI4DTHAMa4zsCZe3lEgXAXfki2JtaOf4v4KIvTc7bZf95bvFnkL/N5BO2WXWsb1gOkk6AeJqz88tab5hkmLzXtIJHCQtXeQKFtvQrVWqDOLw8ELr/kLijVqeYbtlMzQZOiml+K5mGnW32HsKciyKcXNHh/qpBB0MTNK9mnRjVk84upC2QiI8SpyIfLg1M57Cz5/RuzrzVcl devops@master"

}


resource "aws_instance" "web" {
  count  =  3
  instance_type  = "t2.micro"
  ami   = "ami-090f10efc254eaf55"
  key_name = "${aws_key_pair.devops.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

# Same Subnet as of ELB.

  subnet_id = "${aws_subnet.default.id}"

# Running remote provisioner on instances to install nginx
  tags = {
    Name = "ubuntu"
  }

  connection {
    type = "ssh"
    user = "devops"
    agent = false
    host = "self.public_ip"
    private_key = "${file("/home/devops/.ssh/id_rsa")}"
    timeout = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }

}

