provider "datadog" {}

resource "datadog_monitor" "high_error_rate" {
  name = "High HTTP 5xx rate"
  type = "metric alert"
  query = "avg(last_5m):sum:aws.elb.httpcode_backend_5xx{*} > 1"
  message = "High 5xx errors detected"
  thresholds = { critical = 1 }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol = "email"
  endpoint = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.name}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  dimensions = { ClusterName = var.ecs_cluster_name }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.name}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB in bytes
  dimensions = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
