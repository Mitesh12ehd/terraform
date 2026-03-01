provider "aws"{
    region = "ap-south-1"
    access_key = "abc"
    secret_key = "abc"
}

variable "subnet_cidr_block" {
    description = "subnet cidr block" 
    default = "10.0.10.0/24"
}

resource "aws_vpc" "deployment-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name: "development-vpc"
    vpc-env: "dev"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.deployment-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "ap-south-1a"
  tags = {
    Name: "dev-subnet-1"
  }
}

data "aws_vpc" "existing_vpc"{
    default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.48.0/20"
  availability_zone = "ap-south-1a"
  tags = {
    Name: "dev-subnet-2"
  }
}

output "dev-vpc-id" {
    # We can print any attribute, we can see other attribute in plan
    # for vpc, we have cidr_block, arn, region, tags, main_route_table_id, ipv6_cidr_block etc.
    value = aws_vpc.deployment-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id
}