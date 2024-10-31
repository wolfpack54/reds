variable "environment" {
  type    = string
  default = "non-prod"
}

# Define SNS topics for notifications based on environment
data "aws_sns_topic" "alarm_topic" {
  name = var.environment == "prod" ? "prod-alarm-topic" : "non-prod-alarm-topic"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name           = "${var.environment}-cpu-utilization-high"
  comparison_operator  = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name          = "CPUUtilization"
  namespace            = "AWS/Redshift"
  period               = 300
  statistic            = "Average"
  threshold            = var.environment == "prod" ? 80 : 90
  alarm_description    = "This metric monitors Redshift CPU utilization for ${var.environment} environment"
  actions_enabled      = true
  alarm_actions        = [data.aws_sns_topic.alarm_topic.arn]
  dimensions = {
    ClusterIdentifier = "my-redshift-cluster"
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name           = "${var.environment}-memory-utilization-high"
  comparison_operator  = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name          = "MemoryUtilization"
  namespace            = "AWS/Redshift"
  period               = 300
  statistic            = "Average"
  threshold            = var.environment == "prod" ? 75 : 85
  alarm_description    = "This metric monitors Redshift memory utilization for ${var.environment} environment"
  actions_enabled      = true
  alarm_actions        = [data.aws_sns_topic.alarm_topic.arn]
  dimensions = {
    ClusterIdentifier = "my-redshift-cluster"
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections_alarm" {
  alarm_name           = "${var.environment}-database-connections-high"
  comparison_operator  = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name          = "DatabaseConnections"
  namespace            = "AWS/Redshift"
  period               = 300
  statistic            = "Average"
  threshold            = var.environment == "prod" ? 100 : 150
  alarm_description    = "This metric monitors Redshift database connections for ${var.environment} environment"
  actions_enabled      = true
  alarm_actions        = [data.aws_sns_topic.alarm_topic.arn]
  dimensions = {
    ClusterIdentifier = "my-redshift-cluster"
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "redshift_health_alarm" {
  alarm_name           = "${var.environment}-redshift-health-check"
  comparison_operator  = "LessThanThreshold"
  evaluation_periods   = 2
  metric_name          = "HealthStatus"
  namespace            = "AWS/Redshift"
  period               = 300
  statistic            = "Average"
  threshold            = 1
  alarm_description    = "This metric monitors Redshift cluster health for ${var.environment} environment"
  actions_enabled      = true
  alarm_actions        = [data.aws_sns_topic.alarm_topic.arn]
  dimensions = {
    ClusterIdentifier = "my-redshift-cluster"
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "prod_alarm_topic" {
  count = var.environment == "prod" ? 1 : 0
  name  = "prod-alarm-topic"
}

resource "aws_sns_topic" "non_prod_alarm_topic" {
  count = var.environment == "non-prod" ? 1 : 0
  name  = "non-prod-alarm-topic"
}
