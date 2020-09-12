resource "aws_security_group" "elb" {
  name        = "My-ELB-SG"
  description = "Allow http inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "My-ELB-SG"
  }
}


data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "s3-test" {
  bucket = "my-elb-tf-test-bucket-20201009"
  force_destroy = "true"

  tags = {
  Name = "MyBucket"
  Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "s3-test" {
  bucket = aws_s3_bucket.s3-test.id

  policy = <<POLICY
{
  "Id": "Policy1599699091147",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1599699083688",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::my-elb-tf-test-bucket-20201009/*",
      "Principal": {
        "AWS": [
        "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_security_groups" "test" {
  depends_on = [ aws_security_group.elb ]
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_elb" "elb-test" {
  name = var.elb_name
  availability_zones = data.aws_availability_zones.available.names
  security_groups = data.aws_security_groups.test.ids
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  access_logs {
    bucket   = aws_s3_bucket.s3-test.bucket
    bucket_prefix = "logs"
    interval      = 5
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

#  listener {
#    instance_port      = 8080
#    instance_protocol  = "http"
#    lb_port            = 443
#    lb_protocol        = "https"
#    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
#  }

    # For accessing servers from Load Balancer DNS or IP
#    listener {
#    instance_port     = 22
#    instance_protocol = "tcp"
#    lb_port           = 22
#    lb_protocol       = "tcp"
#    }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 30
  }

  tags = {
    Owner       = "devops"
    Environment = "test"
  }
}

output "elb_id" {
  value = aws_elb.elb-test.id
}

output "elb-sg-id" {
  value = aws_security_group.elb.id
}