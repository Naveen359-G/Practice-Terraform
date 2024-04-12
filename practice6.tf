# Define variables
variable "domain_name" {
  description = "Domain name for the website (e.g., example.com)"
}

variable "s3_bucket_name" {
  description = "Name for the S3 bucket"
}

# Configure AWS provider
provider "aws" {
  region = "us-west-2" # Replace with your desired region
}

# Create S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.s3_bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "Website Bucket"
  }
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.s3_bucket_name}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3-${var.s3_bucket_name}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.s3_bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "Production"
  }
}

# Output CloudFront distribution domain name
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website_distribution.domain_name
}
