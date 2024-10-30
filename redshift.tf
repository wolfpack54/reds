# Security Group for Redshift
resource "aws_security_group" "redshift_sg" {
  name        = "${var.cluster_identifier}-sg"
  description = "Security group for Redshift cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Redshift access"
    from_port   = 5439
    to_port     = 5439
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

# Redshift Subnet Group
resource "aws_redshift_subnet_group" "redshift" {
  name       = "${var.cluster_identifier}-subnet-group"
  description = "Subnet group for Redshift cluster"
  subnet_ids = var.subnet_ids
}

# Redshift Parameter Group
resource "aws_redshift_parameter_group" "redshift" {
  name   = "${var.cluster_identifier}-param-group"
  family = "redshift-1.0"

  # Add any necessary parameters here
  parameter {
    name  = "require_ssl"
    value = "true"
  }
}

# IAM Role for Redshift to access S3 logs
resource "aws_iam_role" "redshift_logging_role" {
  name = "${var.cluster_identifier}-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonS3FullAccess Policy to Redshift Logging Role
resource "aws_iam_policy_attachment" "redshift_full_s3_access" {
  name       = "${var.cluster_identifier}-full-s3-access"
  roles      = [aws_iam_role.redshift_logging_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Redshift Cluster
resource "aws_redshift_cluster" "redshift" {
  cluster_identifier        = var.cluster_identifier
  database_name             = var.database_name
  master_username           = var.master_username
  master_password           = var.master_password
  node_type                 = var.node_type
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift.name
  cluster_parameter_group_name = aws_redshift_parameter_group.redshift.name
  number_of_nodes           = var.number_of_nodes
  vpc_security_group_ids    = [aws_security_group.redshift_sg.id]
  publicly_accessible       = true

  # Associate IAM role for S3 logging
  iam_roles = [aws_iam_role.redshift_logging_role.arn]

  # Optional security configurations
  encrypted = true
}

# Redshift Logging Configuration
resource "aws_redshift_logging" "redshift_logging" {
  cluster_identifier = aws_redshift_cluster.redshift.cluster_identifier
  bucket_name        = var.s3_logging_bucket
  s3_key_prefix      = "${var.cluster_identifier}/logs/"
}

# S3 Bucket Policy for Logging Permissions
resource "aws_s3_bucket_policy" "redshift_logging_policy" {
  bucket = var.s3_logging_bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow Redshift to write logs to the bucket
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketAcl"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_logging_bucket}",                    
          "arn:aws:s3:::${var.s3_logging_bucket}/${var.cluster_identifier}/logs/*"  
        ]
      }
    ]
  })
}


