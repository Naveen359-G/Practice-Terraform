# Define variables
variable "instance_ami" {
  default = "ami-12345678" # Replace with appropriate AMI
}

# Configure AWS provider
provider "aws" {
  region = "us-west-2" # Replace with your desired region
}

# Create EC2 instance
resource "aws_instance" "example_instance" {
  ami           = var.instance_ami
  instance_type = "t2.micro"
  tags = {
    Name = "example-instance"
  }
}

# Create CloudWatch metric alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = ["arn:aws:sns:us-west-2:123456789012:example-sns-topic"]
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }
}

# Create CloudWatch metric alarm for memory utilization
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "memory-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_actions       = ["arn:aws:sns:us-west-2:123456789012:example-sns-topic"]
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }
}

# Create CloudWatch log group
resource "aws_cloudwatch_log_group" "example_log_group" {
  name              = "/var/log/application"
  retention_in_days = 14
}

# Create CloudWatch log stream for EC2 instance
resource "aws_cloudwatch_log_stream" "example_log_stream" {
  name           = "example-log-stream"
  log_group_name = aws_cloudwatch_log_group.example_log_group.name
}

# Configure CloudWatch agent on EC2 instance
resource "aws_cloudwatch_agent" "example_agent" {
  name               = "example-agent"
  configuration_file = <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/application/*.log",
            "log_group_name": "${aws_cloudwatch_log_group.example_log_group.name}",
            "log_stream_name": "${aws_cloudwatch_log_stream.example_log_stream.name}"
          }
        ]
      }
    }
  }
}
EOF

# Output
output "instance_id" {
  value = aws_instance.example_instance.id
}
