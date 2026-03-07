// region and access key pair taken from env directly
provider "aws"{
    region = "ap-south-1"
}

variable "vpc_cidr_block" {}
variable "private_subnet_cidr_blocks" {}
variable "public_subnet_cidr_blocks" {}

// to query availability zone available in current region
data "aws_availability_zones" "azs" {}

module "myapp-vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "6.6.0"

    name = "myapp-vpc"
    cidr = var.vpc_cidr_block

    // subnets 
    // best practice : there should 1 public and 1 private subnet for each az in our region
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks
    azs = data.aws_availability_zones.azs.names

    enable_nat_gateway = true
    single_nat_gateway = true

    // to get dns names attached to ip that we need to access it from browser
    enable_dns_hostnames = true

    // tags to give information to kubernetes to use this subnet and resources
    tags = {
        // label to identify resource
        // it tell kubernetes this vpc is belongs to eks cluster
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    }
    public_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1
    }
    private_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }
}