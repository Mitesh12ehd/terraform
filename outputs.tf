output "ec2-instance-public-ip"{
    # value = aws_instance.myapp-server.public_ip
    value = module.myapp-server.instance.public_ip 
}