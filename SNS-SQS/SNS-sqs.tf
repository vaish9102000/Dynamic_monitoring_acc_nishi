resource "aws_sns_topic" "sns_to_sqs" {
  name         = "sns-to-sqs"
  display_name = "SNS to SQS"
}

resource "aws_sqs_queue" "sns_to_sqs" {
  name = "sns-to-sqs"
}

resource "aws_sns_topic_subscription" "my_subscription" {
    depends_on = [aws_sns_topic.sns_to_sqs, aws_sqs_queue.sns_to_sqs]
  topic_arn = aws_sns_topic.sns_to_sqs.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sns_to_sqs.arn
}

# Create SQS deadletter queue 
resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = "sns-to-sqs-deadletter-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sns_to_sqs.arn
    maxReceiveCount     = 4
  })
}


resource "aws_sqs_queue_policy" "access_policy" {
  queue_url = aws_sqs_queue.sns_to_sqs.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow-SNS-to-Publish-to-SQS"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.sns_to_sqs.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.sns_to_sqs.arn
          }
        }
      }
    ]
  })
}
