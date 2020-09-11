provider "aws" {
  version = "~> 2.30"
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

/*
  NAT Instance Security Group
*/
resource "aws_security_group" "sg_terra" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"] # add a CIDR block here
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.private_subnet_cidr}"] # add a CIDR block here
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.private_subnet_cidr}"] # add a CIDR block here
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"] # add a CIDR block here
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     Name = "natsg"
    }
}

/*
  NAT Instance
*/
resource "aws_instance" "nat" {
    ami = "${data.aws_ami.ubuntu.id}" # this is a special ami preconfigured to do NAT
    availability_zone = "${var.aws_region_zone}"
    instance_type = "${var.aws_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.sg_terra.id}"]
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
     Name = "Nat Instance"
    }
}

/*
  Private Subnet
*/
resource "aws_subnet" "my_private_subnet" {
   vpc_id = "vpc-4cb48627"
   cidr_block = "${var.private_subnet_cidr}"
   availability_zone = "${var.aws_region_zone}"

   tags = {
     Name = "Private-subnet"
    }
}

resource "aws_route_table" "my_private_subnet" {
    vpc_id = "vpc-4cb48627"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    tags = {
        Name = "Private-Subnet"
    }
}

resource "aws_route_table_association" "my_private_subnet" {
    subnet_id = "${aws_subnet.my_private_subnet.id}"
    route_table_id = "${aws_route_table.my_private_subnet.id}"
}


/*
  Instance AMI
*/
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

/*
  Web Servers
*/
resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."
#    vpc_id = "${aws_vpc.main.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    egress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    tags = {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "web1" {
   count = "${var.instance_count}"
   ami = "${data.aws_ami.ubuntu.id}"
   instance_type = "${var.aws_instance_type}"
   key_name = "${var.aws_key_name}"
   availability_zone = "${var.aws_region_zone}"
   vpc_security_group_ids = ["${aws_security_group.web.id}"]
#   subnet_id = "${aws_subnet.my_public_subnet.id}"
   associate_public_ip_address = true
   source_dest_check = false
#   subnet_id = "${aws_subnet.my_subnet.id}"
#   vpc_security_group_ids = ["${aws_security_group.sg.id}"]
#   network_interface {
#    network_interface_id = "${aws_network_interface.my_network.id}"
#    device_index         = 0
#  }

   tags = {
     Name = "web-server-${count.index + 1}"
   }
}

#resource "aws_eip" "web-1" {
#  count = "${var.instance_count}"
#  instance = "${aws_instance.web1[count.index].id}"
#  vpc = true
#}

/*
  Database Servers
*/
resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections."
#    vpc_id = "${aws_vpc.main.id}"

    ingress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "DBServerSG"
    }
}

resource "aws_instance" "db-1" {
   ami = "${data.aws_ami.ubuntu.id}"
   instance_type = "${var.aws_instance_type}"
   key_name = "${var.aws_key_name}"
   availability_zone = "${var.aws_region_zone}"
   vpc_security_group_ids = ["${aws_security_group.db.id}"]
   subnet_id = "${aws_subnet.my_private_subnet.id}"
   source_dest_check = false

   tags = {
        Name = "DB-Server-1"
    }
}

# Create a new load balancer
resource "aws_elb" "my-elb" {
  name = "terraform-elb"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

#  listener {
#    instance_port      = 80
#    instance_protocol  = "http"
#    lb_port            = 443
#    lb_protocol        = "https"
#    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
#  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

#  instances                   = ["${aws_instance.web1[count.index].id}"]
#  instance_count = "2"
  instances                   = ["${aws_instance.web1[0].id}", "${aws_instance.web1[1].id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}



resource "aws_launch_configuration" "app" {
  count = "${var.instance_count}"
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.aws_instance_type}"
  security_groups = ["${aws_security_group.web.id}"]
  #TODO REMOVE
  key_name = "${var.aws_key_name}"
  name_prefix = "web-server-${count.index + 1}"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y java-1.8.0-openjdk-devel wget git
              export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0
              wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
              sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
              yum install -y apache-maven
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/server
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

  resource "aws_autoscaling_group" "app" {
  count = "${var.instance_count}"
  name = "terra_autoscaling"
  launch_configuration = "${aws_launch_configuration.app[count.index].id}"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
#  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
#  load_balancers    = ["${aws_elb.my-elb}"]
  health_check_type = "EC2"
  min_size = "${var.app_autoscale_min_size}"
  max_size = "${var.app_autoscale_max_size}"
  force_delete = "true"

#  tags = {
#    key = "Group"
#    value = "Group-value"
#    propagate_at_launch = true
#  }
  tags = [
    {
      key = "Name"
      value = "web-server-${count.index + 1}"
      propagate_at_launch = true
    }
  ]
}