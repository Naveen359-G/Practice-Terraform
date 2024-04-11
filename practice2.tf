# Implement Terraform configuration for multi-tier AWS infrastructure: 
Setup VPC, subnets, security groups, EC2 web server, and RDS database server. 
Utilize Terraform modules for improved organization and reusability. 
Implement best practices for network security and resource provisioning



# Define variables
variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_instance_class" {
  default = "db.t2.micro"
}

variable "db_engine" {
  default = "mysql"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Password123!"
}

# Configure AWS provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Create internet gateway
resource "aws_internet_gateway" "app_gateway" {
  vpc_id = aws_vpc.app_vpc.id
}

# Attach internet gateway to VPC
resource "aws_vpc_attachment" "gateway_attachment" {
  vpc_id       = aws_vpc.app_vpc.id
  internet_gateway_id = aws_internet_gateway.app_gateway.id
}

# Create security group for web server
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for database server
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance for web server
resource "aws_instance" "web_instance" {
  ami           = "ami-12345678"  # Replace with appropriate AMI
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl enable httpd",
      "sudo service httpd start"
    ]
  }
}

# Create RDS instance for database server
resource "aws_db_instance" "db_instance" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  name                 = "mydatabase"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  subnet_group_name    = "default"
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "db-server"
  }
}
