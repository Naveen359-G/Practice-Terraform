# Practice-Terraform

This Terraform code (practice.tf) provisions an EC2 instance with a web server running on it, 
along with necessary networking configurations like VPC, subnet, and security groups. 
Additionally, it creates an S3 bucket and configures IAM policies and roles to grant the EC2 instance access to the S3 bucket.

# Prerequisites
Before you start, make sure you have:

- Installed and set up the AWS Command Line Interface (CLI) with your AWS access and secret keys.
- Installed Terraform on your computer.

=> Step 1: Set up AWS CLI
- Install the AWS CLI.
- Configure it with your AWS access and secret keys.

=> Step 2: Configure AWS Provider in Terraform
- In your terraform code (practice.tf) file, add the following:

```JSON
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "<YOUR_ACCESS_KEY>"
  secret_key = "<YOUR_SECRET_KEY>"
}
```

# Step 3: Instance Configuration
After creating the instance:

- Access it using Session Manager.
- Navigate to /etc/ssh.
- Edit the sshd_config file to allow password authentication.
- Set a password for your chosen username with sudo passwd username.
- Now you can SSH into the instance using the password.

# This guide shows how to set up a basic AWS infrastructure using Terraform. You can customize and expand this setup as needed.

# >> practice.tf 
This Terraform code provisions an EC2 instance with a web server running on it, along with necessary networking configurations like VPC, subnet, and security groups. 
Additionally, it creates an S3 bucket and configures IAM policies and roles to grant the EC2 instance access to the S3 bucket.

# >> practice2.tf
This Terraform code Provisions a multi-tier application infrastructure on AWS, consisting of both a web server (EC2 instance) and a database server (RDS instance). 
It highlights the setup of networking configurations such as VPC, subnets, and security groups, with an emphasis on implementing security best practices. 
Additionally, it mentions the use of Terraform modules to organize the code for reusability, which is a good practice for managing infrastructure as code efficiently.

# >> practice3.tf
This Terraform code provisions a highly available architecture on AWS by creating an EC2 instance with Auto Scaling Group, Elastic Load Balancer (ELB), and RDS Multi-AZ deployment. 
It sets up proper networking configurations with VPC, subnets, and security groups, and ensures fault tolerance and scalability for critical components of the application.

# >> practice4.tf
This Terraform code sets up infrastructure monitoring and logging using AWS CloudWatch. It creates EC2 instances with CloudWatch metric alarms for monitoring CPU and memory utilization. 
Additionally, it creates a CloudWatch log group and stream for capturing logs from the EC2 instance. Finally, it configures the CloudWatch agent on the EC2 instance to send logs to the specified log group.

# >> practice5.tf
This Terraform code provisions a fault-tolerant and scalable infrastructure on AWS with an EC2 instance running Nginx, an RDS database, and sets up monitoring for the EC2 instance's CPU utilization.
The EC2 instance's user data is updated to include commands for installing the MySQL client and creating a database on the RDS instance.
Including a database in the infrastructure adds complexity but can significantly enhance the capabilities of the application.

# >> practice6.tf
This Terraform code creates an S3 bucket for hosting the static website and configures it for static website hosting. 
It then creates a CloudFront distribution to serve as a content delivery network (CDN) in front of the S3 bucket, enabling faster content delivery globally. 
* Need to adjust the variables and configurations as needed for your specific website deployment.

===============================================================================================================================================================================================================================


