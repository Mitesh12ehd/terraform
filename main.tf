// region and access key pair taken from env directly
provider "aws"{}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable availability_zone {}
variable env_prefix {}      // prefix like dev, prod etc..
variable instance_type {}
variable ssh_key {}

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
        cidr_block = "0.0.0.0/0"        // to allow everyone
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
        // range of port
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

// for ami image to create EC2 
data "aws_ami" "amazon-linux-image"{
    most_recent = true

    // get it from aws console
    owners = ["amazon"]

    // we got all the image which follow below filters
    filter {
        // "AMI name" of image we want to match
        // Copy image id from while create EC2 > Search in AMI section > go into image > copy API name
        name   = "name"
        values = ["al2023-ami-*-kernel-6.1-x86_64"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-key"{
    key_name = "my-app-key-pair"
    public_key = file(var.ssh_key)
}

output "amazon-linux-image-id" {
    value = data.aws_ami.amazon-linux-image.id
}
output "ec2-instance-public-ip"{
    value = aws_instance.myapp-server.public_ip
}

resource "aws_instance" "myapp-server"{
    // ami image id can be change in version upgrade and region wise
    // we can't take static copied from aws console
    ami = data.aws_ami.amazon-linux-image.id

    instance_type = var.instance_type

    tags = {
        Name: "${var.env_prefix}-server"
    }

    // to end up this ec2 instance in our subnet
    // private ip of ec2 instance is withing our subnet cidr block
    subnet_id = aws_subnet.my-app-subnet-1.id

    // to assign security groups for our ec2
    vpc_security_group_ids = [aws_security_group.myapp-security-group.id]

    availability_zone = var.availability_zone

    // Assign public ip, so we can use it for ssh, application browser access etc..
    associate_public_ip_address = true

    // associate key pair   
    key_name = "my-app-key-pair"

    // to run nginx container
    user_data = file("entryscript.sh")
    
    // it destroy and create ec2 instance, if we update script in user_data
    user_data_replace_on_change = true
    
}