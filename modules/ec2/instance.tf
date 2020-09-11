resource "aws_instance" "web" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  count = var.ec2_count
  key_name = var.key
  associate_public_ip_address = "true"
  user_data = file("config/userdata.sh")
#  availability_zone = lookup(var.az, count.index)

  tags = {
    Name = "WebServer${1+count.index}"
  }
}
