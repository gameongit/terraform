# Get the security group names under a single vpc id
data "aws_security_groups" "test" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_security_group" "webservers" {
  name        = "My-Webservers-SG"
  description = "For Webservers traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${var.elb-sg-id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "My-Webservers-SG"
  }
}

# Get the availabilities details
data "aws_availability_zones" "available" {
  state = "available"
}

## Creating Launch Configuration
resource "aws_launch_configuration" "example" {
  name_prefix            = var.name_prefix
  image_id               = var.image_id
  instance_type          = var.instance_type
  security_groups = [aws_security_group.webservers.id]
  key_name               = var.key
  user_data              = filebase64("config/userdata.sh")
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  name = var.asg_name
  launch_configuration = aws_launch_configuration.example.id
  availability_zones = data.aws_availability_zones.available.names
  min_size = var.min_size
  max_size = var.max_size
  load_balancers = [ var.elb_id ]
  health_check_type = var.health_check_type
  tag {
    key = "Name"
    value = "WebServer"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "instances_autoscaling_policy" {
        name = var.aspolicy_name
        autoscaling_group_name = aws_autoscaling_group.example.name
        adjustment_type = var.adjustment_type
#        scaling_adjustment = var.scaling_adjustment
#        cooldown = var.cooldown
        policy_type = var.policy_type
        target_tracking_configuration {
            predefined_metric_specification {
                predefined_metric_type = "ASGAverageCPUUtilization"
            }

            target_value = var.target_value
        }


}