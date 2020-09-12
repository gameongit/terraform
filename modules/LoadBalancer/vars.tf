variable "ami_id" {}
variable "instance_type" {}
variable "key" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "ec2_count" {}
variable "elb_name" {}
variable "elb_id" {}
variable "elb-sg-id" {}
variable "zones" {
    default = {
        zone0 = "eu-central-1a"
        zone1 = "eu-central-1b"
        zone2 = "eu-central-1c"
    }
}
variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = true
}
variable "enable_cross_zone_load_balancing" {
  description = "Indicates whether cross zone load balancing should be enabled in application load balancers."
  type        = bool
  default     = true
}

