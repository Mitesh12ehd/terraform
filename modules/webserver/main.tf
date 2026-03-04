resource "aws_security_group" "myapp-security-group" {
    vpc_id = var.vpc_id

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
    subnet_id = var.subnet_id

    // to assign security groups for our ec2
    vpc_security_group_ids = [aws_security_group.myapp-security-group.id]

    availability_zone = var.availability_zone

    // Assign public ip, so we can use it for ssh, application browser access etc..
    associate_public_ip_address = true

    // associate key pair   
    key_name = "server-key-pair"

    // to run nginx container
    user_data = file("entryscript.sh")
    
    // it destroy and create ec2 instance, if we update script in user_data
    user_data_replace_on_change = true
    
}