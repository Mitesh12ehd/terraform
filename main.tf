// region and access key pair taken from env directly
provider "aws"{}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "my-app-subnet" {
    source = "./modules/subnet"
    vpc_cidr_block = var.vpc_cidr_block
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    env_prefix = var.env_prefix
    instance_type = var.instance_type
    subnet_id = module.my-app-subnet.subnet.id
    availability_zone = var.availability_zone
}
