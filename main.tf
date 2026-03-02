# region and access key pair taken from env directly
provider "aws"{}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable availability_zone {}
variable env_prefix {}      # prefix like dev, prod etc..

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-app-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "my-app-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-internet-gateway"
    }
}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route{
        cidr_block = "0.0.0.0/0"        # to allow everyone
        gateway_id = aws_internet_gateway.my-app-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-route-table"
    }
}

resource "aws_route_table_association" "association-route-table-subnet" {
    subnet_id = aws_subnet.my-app-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-security-group" {
    name = "myapp-security-group"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        # range of port
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]   
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]   
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-security-group"
    }
}