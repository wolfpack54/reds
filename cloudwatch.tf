# SNS Topic for Alarm Notifications
resource "aws_sns_topic" "cloudwatch_alarms_topic" {
  name = var.sns_topic_name
}

# CloudWatch Alarm for Redshift CPU Utilization > 80%
resource "aws_cloudwatch_metric_alarm" "redshift_cpu_utilization" {
  alarm_name          = "${var.cluster_identifier}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/Redshift"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm for Redshift CPU utilization greater than or equal to 80%"
  dimensions = {
    ClusterIdentifier = aws_redshift_cluster.redshift.cluster_identifier
  }
  alarm_actions = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

# CloudWatch Alarm for Redshift Memory Utilization > 80%
resource "aws_cloudwatch_metric_alarm" "redshift_memory_utilization" {
  alarm_name          = "${var.cluster_identifier}-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "PercentageDiskSpaceUsed"
  namespace           = "AWS/Redshift"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm for Redshift memory utilization greater than or equal to 80%"
  dimensions = {
    ClusterIdentifier = aws_redshift_cluster.redshift.cluster_identifier
  }
  alarm_actions = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}
