 # Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "sqs_policy" {
  name = "Lambda-cloudwatch-custom_policy"
  role = aws_iam_role.lambda_execution_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:ListServices",
                "cloudwatch:ListMetricStreams",
                "cloudwatch:ListServiceLevelObjectives",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:GenerateQuery",
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:GetService",
                "cloudwatch:GetMetricStream",
                "cloudwatch:GetMetricWidgetImage",
                "cloudwatch:GetServiceData",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:DeleteMetricStream",
                "cloudwatch:DeleteInsightRules",
                "cloudwatch:DisableAlarmActions",
                "cloudwatch:DisableInsightRules",
                "cloudwatch:EnableAlarmActions",
                "cloudwatch:EnableInsightRules",
                "cloudwatch:Link",
                "cloudwatch:PutCompositeAlarm",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:PutMetricData",
                "cloudwatch:PutMetricStream",
                "cloudwatch:SetAlarmState",
                "cloudwatch:StartMetricStreams",
                "cloudwatch:StopMetricStreams",
                "cloudwatch:UpdateServiceLevelObjective",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "sqs:GetQueueUrl",
                "sqs:ReceiveMessage",
                "sqs:SendMessage",
                "sqs:DeleteMessage",
                "sqs:ChangeMessageVisibility",
                "sqs:GetQueueAttributes",
                "sqs:ListQueues",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "sns:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}
 

data "archive_file" "zipit" {
  type        = "zip"
  source_file = "Lambda/lambda_function.py"
  output_path = "lambda_function.zip"
}
 
# Create the Lambda function
resource "aws_lambda_function" "ec2_monitoring_function" {
  function_name = "EC2MonitoringFunction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  memory_size   = 128
  timeout       = 60
 
  # Lambda function code
 filename = "lambda_function.zip"  # Zip file containing your function code
source_code_hash = "${data.archive_file.zipit.output_base64sha256}"

environment {
  variables = {
    SNS_TOPIC_ARN = var.SNS_TOPIC_ARN
  }
}
}

# Create the Lambda function 2
resource "aws_lambda_function" "ec2_monitoring_function1" {
  function_name = "EC2MonitoringFunction1"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  memory_size   = 128
  timeout       = 60
 
  # Lambda function code
 filename = "lambda_function.zip"  # Zip file containing your function code
source_code_hash = "${data.archive_file.zipit.output_base64sha256}"

environment {
  variables = {
    SNS_TOPIC_ARN = var.SNS_TOPIC_ARN
  }
}
}
 
# CloudWatch Event Rule to trigger the Lambda function periodically
resource "aws_cloudwatch_event_rule" "every_two_hour" {
  name                = "TriggerEveryFiveMinutes"
  schedule_expression = "rate(2 hours)"
}
 
# CloudWatch Event Target to invoke the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.every_two_hour.name
  target_id = "EC2MonitoringLambda"
  arn       = aws_lambda_function.ec2_monitoring_function.arn
}
 
# Permission to allow CloudWatch to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_monitoring_function.function_name
principal = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_two_hour.arn
}
