variable "aws_role" {
  description = "Role for executing terraform"
  default     = "arn:aws:iam::738595784977:role/Developer"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

variable "aws_ami" {
  default  = "ami-007d5db58754fa284"
}

