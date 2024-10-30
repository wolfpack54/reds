# Variable Definitions
variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = "us-east-1"  
}

variable "cluster_identifier" {
  description = "Redshift Cluster Identifier"
  type        = string
  default     = "my-redshift-cluster"
}

variable "database_name" {
  description = "Redshift database name"
  type        = string
  default     = "mydb"
}

variable "master_username" {
  description = "Master username for Redshift cluster"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for Redshift cluster"
  type        = string
  default     = "YourStrongPassword123!"
  sensitive   = true
}

variable "node_type" {
  description = "Redshift node type"
  type        = string
  default     = "dc2.large"  
}

variable "number_of_nodes" {
  description = "Number of nodes in the Redshift cluster"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redshift subnet group"
  type        = list(string)
  default     = ["subnet-0fff296c15fbcdc6e", "subnet-0e53aa2ce268b39f3"]  
}

variable "vpc_id" {
  description = "VPC ID where Redshift will be deployed"
  type        = string
  default     = "vpc-082862942b8154403"  
}

variable "s3_logging_bucket" {
  description = "S3 bucket for Redshift audit logs"
  type        = string
  default     = "cxsvartest"  
}

# Variables for SNS
variable "sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarm notifications"
  type        = string
  default     = "redshift-alerts"
}
