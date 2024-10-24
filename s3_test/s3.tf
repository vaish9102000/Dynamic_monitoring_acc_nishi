# Create SNS topic for AWS Config notifications
resource "aws_sns_topic" "config_sns_topic" {
  name = "aws-config-sns-topic"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.config_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.terraform_queue.arn
}

# Create SQS deadletter queue 
resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = "terraform-example-deadletter-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "terraform_queue" {
  name = "terraform-example-queue"
}
 
# AWS Config Role
resource "aws_iam_role" "config_role" {
  name = "aws-config-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
Service = "config.amazonaws.com"
        }
      }
    ]
  })
}
 
resource "aws_s3_bucket_policy" "config_bucket_policy" {
bucket = var.s3_bucket_name
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
Service = "config.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow",
        Principal = {
Service = "config.amazonaws.com"
        },
        Action = "s3:GetBucketAcl",
        Resource = var.s3_bucket_arn
      }
    ]
  })
}
 
# Enable AWS Config Recorder
resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.config_role.arn 
recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = ["AWS::CloudWatch::Alarm"]
  }
}
 
# Deliver AWS Config logs to S3
resource "aws_config_delivery_channel" "config_channel" {
depends_on = [aws_config_configuration_recorder.config_recorder]
  name           = "aws-config-delivery-channel"
  s3_bucket_name = var.s3_bucket_name
  sns_topic_arn  = aws_sns_topic.config_sns_topic.arn
}
 
# Ensure the recorder is started
resource "aws_config_configuration_recorder_status" "config_recorder_status" {
depends_on = [aws_config_delivery_channel.config_channel]
name = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
}
