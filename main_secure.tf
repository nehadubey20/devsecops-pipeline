provider "aws" {
  region = "us-east-1"
  # credentials via environment variables, never hardcoded
}

# Secure S3 bucket — private, encrypted, logging enabled
resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-company-data-bucket"
}

resource "aws_s3_bucket_acl" "data_bucket_acl" {
  bucket = aws_s3_bucket.data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "data_bucket_block" {
  bucket                  = aws_s3_bucket.data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket_enc" {
  bucket = aws_s3_bucket.data_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Secure security group — only port 443
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Web server security group"

  ingress {
    from_port   = 443
    to_port     = 443
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

# Secure IAM — least privilege
resource "aws_iam_role_policy" "app_policy" {
  name = "app-policy"
  role = "my-app-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::my-company-data-bucket/*"
      }
    ]
  })
}

# Secure RDS — encrypted, not public
resource "aws_db_instance" "app_db" {
  identifier          = "app-database"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = var.db_password
  storage_encrypted   = true
  publicly_accessible = false
  skip_final_snapshot = false
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}