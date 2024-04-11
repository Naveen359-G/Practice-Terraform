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

-  terraform {
-  required_providers {
-    aws = {
-      source  = "hashicorp/aws"
-      version = "4.66.1"
-    }
-  }
- }

- provider "aws" {
-  region     = "us-east-2"  # Change region if needed
-  access_key = "<YOUR_ACCESS_KEY>"
-  secret_key = "<YOUR_SECRET_KEY>"
- }

# Step 3: Instance Configuration
After creating the instance:

- Access it using Session Manager.
- Navigate to /etc/ssh.
- Edit the sshd_config file to allow password authentication.
- Set a password for your chosen username with sudo passwd username.
- Now you can SSH into the instance using the password.

# Conclusion
This guide shows how to set up a basic AWS infrastructure using Terraform. You can customize and expand this setup as needed.
