resource "aws_iam_role_policy" "sqs_policy" {
  name = "sns_sqs_policy"
  role = aws_iam_role.Splunk_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
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
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role" "Splunk_role" {
  name = "Splunk_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

# Attach policies to the IAM role
resource "aws_iam_policy_attachment" "Config_policy" {
  name       = "AWS_ConfigRole"
  roles = [aws_iam_role.Splunk_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}