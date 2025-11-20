resource "aws_sns_topic" "dr_failover" {
  name = "${var.project_name}-${var.environment}-dr-failover"
}

resource "aws_sns_topic_subscription" "github_webhook" {
  topic_arn = aws_sns_topic.dr_failover.arn
  protocol  = "https"
  endpoint  = "https://api.github.com/repos/${var.github_repo}/dispatches"
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_failed" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-cluster-failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "cluster_failed_node_count"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors EKS cluster health"
  alarm_actions       = [aws_sns_topic.dr_failover.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "application_pods_down" {
  alarm_name          = "${var.project_name}-${var.environment}-pods-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_ready"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors application pod health"
  alarm_actions       = [aws_sns_topic.dr_failover.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
    Namespace   = "default"
    Service     = "business-management-app"
  }
}