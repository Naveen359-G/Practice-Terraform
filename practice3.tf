# Define variables
variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
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
resource "aws_vpc" "ha_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.ha_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.ha_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Create internet gateway
resource "aws_internet_gateway" "ha_gateway" {
  vpc_id = aws_vpc.ha_vpc.id
}

# Attach internet gateway to VPC
resource "aws_vpc_attachment" "gateway_attachment" {
  vpc_id       = aws_vpc.ha_vpc.id
  internet_gateway_id = aws_internet_gateway.ha_gateway.id
}

# Create security group for web server
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.ha_vpc.id

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

# Create Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name             = "web-asg"
  launch_configuration = aws_launch_configuration.web_lc.name
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.private_subnet.id]

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }
}

# Create Launch Configuration
resource "aws_launch_configuration" "web_lc" {
  name                 = "web-lc"
  image_id             = "ami-12345678"  # Replace with appropriate AMI
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.web_sg.name]
}

# Create Elastic Load Balancer
resource "aws_elb" "web_elb" {
  name               = "web-elb"
  availability_zones = ["us-west-2a", "us-west-2b"]
  subnets            = [aws_subnet.public_subnet.id]
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
}

# Create RDS Multi-AZ deployment
resource "aws_db_instance" "db_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = var.db_engine
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = var.db_username
  password             = var.db_password
  multi_az             = true
}

# Output
output "web_elb_dns" {
  value = aws_elb.web_elb.dns_name
}
