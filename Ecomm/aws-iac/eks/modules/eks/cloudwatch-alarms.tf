resource "aws_sns_topic" "dr_failover" {
  name = "${var.project_name}-${var.environment}-dr-failover-v2"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "dr_trigger.zip"
  source {
    content = <<EOF
import json
import urllib3
import os

def handler(event, context):
    github_token = os.environ['GITHUB_TOKEN']
    github_repo = os.environ['GITHUB_REPO']
    
    if not github_token:
        return {'statusCode': 200, 'body': 'No GitHub token configured'}
    
    http = urllib3.PoolManager()
    
    url = f"https://api.github.com/repos/{github_repo}/dispatches"
    
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
    
    data = {
        'event_type': 'cloudwatch-alarm',
        'client_payload': {
            'alarm': event['Records'][0]['Sns']['Subject'],
            'message': event['Records'][0]['Sns']['Message']
        }
    }
    
    response = http.request('POST', url, 
                          body=json.dumps(data).encode('utf-8'),
                          headers=headers)
    
    return {
        'statusCode': 200,
        'body': json.dumps('DR pipeline triggered successfully')
    }
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "dr_trigger" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-dr-trigger"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

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

# Remove any existing HTTPS subscriptions
resource "null_resource" "cleanup_https_subscription" {
  provisioner "local-exec" {
    command = "aws sns list-subscriptions-by-topic --topic-arn ${aws_sns_topic.dr_failover.arn} --query 'Subscriptions[?Protocol==`https`].SubscriptionArn' --output text | xargs -r aws sns unsubscribe --subscription-arn"
  }
  depends_on = [aws_sns_topic.dr_failover]
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.dr_failover.arn
}

# Alarm that triggers when EKS nodes are unhealthy
resource "aws_cloudwatch_metric_alarm" "eks_nodes_down" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-nodes-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "cluster_node_count"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Triggers DR when EKS nodes are down"
  alarm_actions       = [aws_sns_topic.dr_failover.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.cluster_name
  }
}

# Manual trigger alarm - set this to ALARM state to test DR
resource "aws_cloudwatch_metric_alarm" "manual_dr_trigger" {
  alarm_name          = "${var.project_name}-${var.environment}-manual-dr-trigger"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Manual DR trigger - change threshold to -1 to trigger DR"
  alarm_actions       = [aws_sns_topic.dr_failover.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = "i-nonexistent"
  }
}