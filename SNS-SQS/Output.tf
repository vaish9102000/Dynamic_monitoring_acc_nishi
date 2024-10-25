output "SNS_TOPIC_ARN" {
  value = aws_sns_topic.sns_to_sqs.id
}
