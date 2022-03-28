# VPC
resource "aws_vpc" "poc-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "coalfire-assessment-vpc"
  }
}

# Sub1 public us-east-1a
resource "aws_subnet" "Sub1-us-east-1a" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = "10.1.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet Sub1 - us-east-1a"
  }
}

# Sub2 public us-east-1b
resource "aws_subnet" "Sub2-us-east-1b" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet Sub2 - us-east-1b"
  }
}

# Sub3 private us-east-1a
resource "aws_subnet" "Sub3-us-east-1a" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet Sub3 - us-east-1a"
  }
}

# Sub4 private us-east-1a
resource "aws_subnet" "Sub4-us-east-1a" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet Sub4 - us-east-1a"
  }
}

# Sub4 private us-east-1b
resource "aws_subnet" "Sub4-us-east-1b" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = "10.1.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet Sub4 - us-east-1b"
  }
}