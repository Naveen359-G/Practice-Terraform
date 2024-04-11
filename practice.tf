provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main-subnet"
  }
}

# Create a security group
resource "aws_security_group" "main" {
  name        = "main-sg"
  description = "Security group for main VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "main" {
  ami           = "ami-0c94855ba95c574c8" # This is an example AMI ID for a t2.micro instance in us-west-2 region
  instance_type = "t2.micro"
  key_name      = "my-key-pair" # Replace with your key pair name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo service httpd start
              sudo echo "<h1>Welcome to Terraform!</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "main-ec2"
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "main" {
  bucket = "my-terraform-bucket" # Replace with your desired bucket name

  tags = {
    Name = "main-s3-bucket"
  }
}

# Create an IAM policy to access the S3 bucket from the EC2 instance
resource "aws_iam_policy" "main" {
  name        = "main-s3-policy"
  description = "Policy to access the S3 bucket from the EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = aws_s3_bucket.main.arn
      }
    ]
  })
}

# Attach the IAM policy to the EC2 instance
resource "aws_iam_instance_profile" "main" {
  name = "main-ec2-profile"

  role = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  name = "main-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

# Associate the IAM role with the EC2 instance
resource "aws_iam_instance_profile_attachment" "main" {
  instance_profile_name = aws_iam_instance_profile.main.name
  instance_id          = aws_instance.main.id
}