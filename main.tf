terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique name for the S3 bucket"
}

# 1. Create S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
}

# 2. Configure Public Access Block Settings (Disable block)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

# 4. Attach Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id

  # Ensure public access settings are altered before applying the policy
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadEverything"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# 5. Output the Website Endpoint URL
output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.hosting.website_endpoint
  description = "The URL of the static website"
}

