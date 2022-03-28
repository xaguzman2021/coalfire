data "http" "my-ip" {
  url = "http://ipv4.icanhazip.com/"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.poc-vpc.id
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.poc-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Route to internet"
  }
}

resource "aws_route_table_association" "rta-public-sub1-us-east-1a" {
  subnet_id      = aws_subnet.Sub1-us-east-1a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "rta-public-sub2-us-east-1b" {
  subnet_id      = aws_subnet.Sub2-us-east-1b.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.poc-vpc.id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    #restrict ssh access to only my ip
    cidr_blocks = ["${chomp(data.http.my-ip.body)}/32"]
  }

  tags = {
    Name = "allow-ssh"
  }
}
