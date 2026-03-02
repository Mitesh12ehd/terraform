#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sleep 10
sudo usermod -aG docker ec2-user   # add ec2-user to docker group, so we can run docker command without sudo
docker run -p 8080:80 nginx