resource "aws_sns_topic" "dr_failover" {
  name = "${var.project_name}-${var.environment}-dr-failover"
}

resource "aws_lambda_function" "dr_trigger" {
  filename         = "dr_trigger.zip"
  function_name    = "${var.project_name}-${var.environment}-dr-trigger"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"

  environment {
    variables = {
      GITHUB_TOKEN = var.github_token
      GITHUB_REPO  = var.github_repo
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-dr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-${var.environment}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.dr_failover.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.dr_trigger.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.dr_failover.arn
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
    ClusterName = var.deploy_secondary ? aws_eks_cluster.gmk-cluster[0].name : var.cluster_name
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
    ClusterName = var.deploy_secondary ? aws_eks_cluster.gmk-cluster[0].name : var.cluster_name
    Namespace   = "default"
    Service     = "business-management-app"
  }
}