provider "aws" {
  shared_credentials_files = ["/home/chris/.aws/credentials"]
  region = "us-east-2"
}

// Modules _must_ use remote state. The provider does not persist state.
# terraform {
#   backend "kubernetes" {
#     secret_suffix     = "providerconfig-default"
#     namespace         = "default"
#     in_cluster_config = true
#   }
# }

######################################################
#### EC2 for Production
######################################################
resource "aws_vpc" "chris_vpc_route53-1" {
  cidr_block = "10.11.0.0/16"

  tags = {
    Name = "chris_vpc_route53-1"
  }
}

resource "aws_subnet" "some_public_subnet-1" {
  vpc_id            = aws_vpc.chris_vpc_route53-1.id
  cidr_block        = "10.11.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Some Public Subnet-1"
  }
}

resource "aws_subnet" "some_private_subnet-1" {
  vpc_id            = aws_vpc.chris_vpc_route53-1.id
  cidr_block        = "10.11.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Some Private Subnet-1"
  }
}

resource "aws_internet_gateway" "some_ig-1" {
  vpc_id = aws_vpc.chris_vpc_route53-1.id

  tags = {
    Name = "Some Internet Gateway-1"
  }
}

resource "aws_route_table" "public_rt-1" {
  vpc_id = aws_vpc.chris_vpc_route53-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig-1.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig-1.id
  }

  tags = {
    Name = "Public Route Table-1"
  }
}

resource "aws_route_table_association" "public_1_rt_a-1" {
  subnet_id      = aws_subnet.some_public_subnet-1.id
  route_table_id = aws_route_table.public_rt-1.id
}

resource "aws_security_group" "web_sg-1" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.chris_vpc_route53-1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance-1" {
  ami           = "ami-04f66ee9914a5c9b1"
  instance_type = "t2.nano"
  key_name      = "ec2keypair"

  subnet_id                   = aws_subnet.some_public_subnet-1.id
  vpc_security_group_ids      = [aws_security_group.web_sg-1.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash

  sudo apt install nginx -y
  #echo "this is production" >  /usr/share/nginx/html/index.html
  #sudo cp /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.bak
  echo "this is production" |  sudo tee /var/www/html/index.nginx-debian.html
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    "Name" : "Production"
  }
}

######################################################
#### EC2 for Canary
######################################################
resource "aws_vpc" "chris_vpc_route53-2" {
  cidr_block = "10.22.0.0/16"

  tags = {
    Name = "chris_vpc_route53-2"
  }
}

resource "aws_subnet" "some_public_subnet-2" {
  vpc_id            = aws_vpc.chris_vpc_route53-2.id
  cidr_block        = "10.22.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Some Public Subnet-2"
  }
}

resource "aws_subnet" "some_private_subnet-2" {
  vpc_id            = aws_vpc.chris_vpc_route53-2.id
  cidr_block        = "10.22.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Some Private Subnet-2"
  }
}

resource "aws_internet_gateway" "some_ig-2" {
  vpc_id = aws_vpc.chris_vpc_route53-2.id

  tags = {
    Name = "Some Internet Gateway-2"
  }
}

resource "aws_route_table" "public_rt-2" {
  vpc_id = aws_vpc.chris_vpc_route53-2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig-2.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig-2.id
  }

  tags = {
    Name = "Public Route Table-2"
  }
}

resource "aws_route_table_association" "public_1_rt_a-2" {
  subnet_id      = aws_subnet.some_public_subnet-2.id
  route_table_id = aws_route_table.public_rt-2.id
}

resource "aws_security_group" "web_sg-2" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.chris_vpc_route53-2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance-2" {
  ami           = "ami-04f66ee9914a5c9b1"
  instance_type = "t2.nano"
  key_name      = "ec2keypair"

  subnet_id                   = aws_subnet.some_public_subnet-2.id
  vpc_security_group_ids      = [aws_security_group.web_sg-2.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash

  sudo apt install nginx -y
  #echo "this is production" >  /usr/share/nginx/html/index.html
  #sudo cp /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.bak
  echo "this is canary" |  sudo tee /var/www/html/index.nginx-debian.html
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    "Name" : "Canary"
  }
}

######################################################
#### Route 53 used to switch from Production to Canary (and back)
######################################################

#Setup a simple A record route for each EC2 above
resource "aws_route53_record" "prod-A" {
  zone_id = "Z0099474UE6G1A66LZAQ"
  name    = "prod.mynethopper.net"
  type    = "A"
  ttl     = 60
  records = [aws_instance.web_instance-1.public_ip]
}

resource "aws_route53_record" "canary-A" {
  zone_id = "Z0099474UE6G1A66LZAQ"
  name    = "canary.mynethopper.net"
  type    = "A"
  ttl     = 60
  records = [aws_instance.web_instance-2.public_ip]
}

# #setup a weight (total 100) between prod.mynethopper.net and canary.mynethopper.net
# # change the xxxx below, and then terraform apply to make the switch

resource "aws_route53_record" "prod-CNAME" {
  zone_id = "Z0099474UE6G1A66LZAQ"
  name    = "active.mynethopper.net"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "prod"
  records        = ["prod.mynethopper.net"]
}

resource "aws_route53_record" "canary-CNAME" {
  zone_id = "Z0099474UE6G1A66LZAQ"
  name    = "active.mynethopper.net"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 0
  }

  set_identifier = "canary"
  records        = ["canary.mynethopper.net"]
}

