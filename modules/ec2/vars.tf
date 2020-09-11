variable "ami_id" {
#  default = "ami-03b40f7f23e44af48"
  default = "ami-07dfba995513840b5"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key" {
  default = "275387897436-Key-pair"
}

#variable "az" {
#  default = {
#    "count" = 3
#    "0" = "eu-central-1a"
#    "1" = "eu-central-1b"
#    "2" = "eu-central-1c"
#  }
#}

variable "subnet_id" {}

variable "ec2_count" {
  default = "1"
}