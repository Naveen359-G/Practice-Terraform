# Define variables
variable "instance_ami" {
  default = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS AMI for us-west-2 region
}

variable "instance_type" {
  default = "t2.micro"
}

# Configure AWS provider
provider "aws" {
  region = "us-west-2" # Default region
}

# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a" # Choose an availability zone
}

# Create security group for EC2 instance
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.example_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "example_role" {
  name = "example-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach IAM policy to role
resource "aws_iam_policy_attachment" "example_policy_attachment" {
  name       = "example-policy-attachment"
  roles      = [aws_iam_role.example_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess" # Example policy for read-only access
}

# Create EC2 instance
resource "aws_instance" "example_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.instance_sg.name]
  iam_instance_profile = aws_iam_role.example_role.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "example-instance"
  }
}

# Create Elastic Load Balancer
resource "aws_elb" "example_elb" {
  name               = "example-elb"
  availability_zones = ["us-west-2a"] # Choose availability zones
  security_groups    = [aws_security_group.instance_sg.name]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "example_asg" {
  launch_configuration = aws_launch_configuration.example_lc.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
}

# Create Launch Configuration
resource "aws_launch_configuration" "example_lc" {
  name                 = "example-lc"
  image_id             = var.instance_ami
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.instance_sg.name]

  lifecycle {
    create_before_destroy = true
  }
}

# Create RDS DB instance
resource "aws_db_instance" "example_db_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql" # Choose appropriate database engine
  instance_class       = "db.t2.micro"
  name                 = "example-db"
  username             = "admin"
  password             = "Password123!" # Replace with a secure password
  multi_az             = true
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
}

# Create CloudWatch alarm for EC2 instance
resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "example-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors CPU utilization"
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }

  alarm_actions = ["arn:aws:sns:us-west-2:123456789012:example-sns-topic"] # Replace with appropriate SNS topic ARN
}
