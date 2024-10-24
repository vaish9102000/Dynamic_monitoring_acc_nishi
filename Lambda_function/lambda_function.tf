# IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name = "SSE_LambdaExecutionRole"
 
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
 
# Attach policies to the IAM role
resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "LambdaPolicyAttachment"
  roles = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
 
# Attach policies to the IAM role
resource "aws_iam_policy_attachment" "lambda_policy_cloudwatch" {
  name       = "LambdaPolicyAttachmentcloudwatch"
  roles = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
 
data "archive_file" "zipit" {
  type        = "zip"
  source_file = "Lambda/lambda_function.py"
  output_path = "lambda_function.zip"
}
 
# Create the Lambda function
resource "aws_lambda_function" "ec2_monitoring_function" {
  function_name = "SSEMonitoringFunction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  memory_size   = 128
  timeout       = 60
 
  # Lambda function code
 filename = "lambda_function.zip"
 source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
}
