resource "aws_vpc" "main" {
   cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
   vpc_id = "${aws_vpc.main.id}"
   availability_zone = "eu-central-1a"
   cidr_block  = "10.0.1.0/24"
}

#resource "aws_internet_gateway" "main" {
#  vpc_id = "${aws_vpc.main.id}"
#}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "main" {
  route_table_id = "${aws_route_table.main.id}"
  destination_cidr_block = "10.0.1.0/24"
 # gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "-1"
    # Please restrict your ingress to only necessary IPs and ports.
#    cidr_blocks = "10.0.1.0/24" # add a CIDR block here
    }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
#    prefix_list_ids = ["pl-12c4e678"]
    }
}
