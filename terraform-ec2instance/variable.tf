variable "aws_role" {
  description = "Role for executing terraform"
  default     = "arn:aws:iam::738595784977:role/Developer"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

variable "aws_ami" {
  type = "map"
  default  = {
   "redhat8" = "ami-02fc41eea185ef7b2"
   "ubuntu" = "ami-090f10efc254eaf55"
  }
}

variable "aws_name" {
  default = "terraclient" 
  }
