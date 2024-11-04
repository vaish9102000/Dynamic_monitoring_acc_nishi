
# IAM Role for SSM and CloudWatch Agents
resource "aws_iam_role" "ec2_ssm_cw_role" {
  name = "EC2SSMandCWRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# IAM Policy for SSM and CloudWatch
resource "aws_iam_policy" "ssm_cw_policy" {
  name = "SSMandCWPolicy"
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "ssm:SendCommand",
          "ssm:ListCommandInvocations",
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "ec2messages:*",
          "ssmmessages:*"
        ],
        Resource: "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_cw_policy_attachment" {
role = aws_iam_role.ec2_ssm_cw_role.name
  policy_arn = aws_iam_policy.ssm_cw_policy.arn
}

resource "aws_iam_instance_profile" "ec2_ssm_cw_profile" {
  name = "EC2SSMandCWProfile"
role = aws_iam_role.ec2_ssm_cw_role.name
}
# # SNS Topic for Notifications
# resource "aws_sns_topic" "alarm_topic" {
#   name = "CloudWatchAlarmTopic"
# }
# # SNS Subscription for Email Notifications
# resource "aws_sns_topic_subscription" "email_subscription" {
#   topic_arn = aws_sns_topic.alarm_topic.arn
#   protocol  = "email"
#   endpoint  = "pavankumarreddy6302@gmail.com"  
# }
# CloudWatch Agent Configuration
resource "aws_ssm_parameter" "cw_agent_config" {
  name  = "AmazonCloudWatch-linux"
  type  = "String"
  value = <<-EOT
  {
    "agent": {
      "metrics_collection_interval": 30,
      "run_as_user": "root"
    },
    "metrics": {
      "append_dimensions": {
        "InstanceId": "{instance_id}"
      },
      "metrics_collected": {
        "cpu": {
          "measurement": [
            "cpu_usage_idle",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval": 30
        },
        "disk": {
          "measurement": [
            "used_percent"
          ],
          "metrics_collection_interval": 30,
          "resources": [
            "/"
          ]
        },
        "mem": {
          "measurement": [
            "mem_used_percent"
          ],
          "metrics_collection_interval": 60
        }
      }
    },
    "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            {
              "file_path": "/var/log/messages",
              "log_group_name": "MyLogGroup",
              "log_stream_name": "{instance_id}",
              "timestamp_format": "%b %d %H:%M:%S"
            }
          ]
        }
      }
    }
  }
  EOT
}

# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "80" 
  alarm_actions       = [var.SNS_TOPIC_ARN]
  dimensions = {
InstanceId = aws_instance.example.id
  }
  tags = {
    Name = "CPUAlarm"
  }
}

# CloudWatch Alarm for Memory Usage
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "HighMemoryUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "30"
  statistic           = "Average"
  threshold           = "75" 
  alarm_actions       = [var.SNS_TOPIC_ARN]
  dimensions = {
InstanceId = aws_instance.example.id
  }
  tags = {
    Name = "MemoryAlarm"
  }
}

# CloudWatch Alarm for Disk Usage
resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  alarm_name          = "HighDiskUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "30"
  statistic           = "Average"
  threshold           = "80"  
  alarm_actions       = [var.SNS_TOPIC_ARN]
  dimensions = {
InstanceId = aws_instance.example.id
  }
  tags = {
    Name = "DiskAlarm"
  }
}

# EC2 instance with SSM and CloudWatch Agent
resource "aws_instance" "example" {
  ami           = var.golden_ami_ids[var.selected_ami_index]  
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_cw_profile.name
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    yum install -y amazon-cloudwatch-agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -s -m ec2 -c ssm:AmazonCloudWatch-linux
    systemctl status amazon-ssm-agent > /var/log/ssm-agent-status.log
    systemctl status amazon-cloudwatch-agent > /var/log/cloudwatch-agent-status.log
  EOF
  tags = {
    Name = "MyEC2Instance"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "sse-key-pair"  # Change to your desired key pair name
  public_key = tls_private_key.example.public_key_pem  
}

# Create a custom security group
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP traffic"
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"] 
  }
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
    cidr_blocks = ["0.0.0.0/0"]  
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch multiple EC2 instances using the selected Golden AMI
resource "aws_instance" "golden_ami_instance" {
  count         = 1
  ami           = var.golden_ami_ids[var.selected_ami_index]  
  instance_type = "t2.micro"  
  key_name      = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.my_security_group.name]
  tags = {
    Name = "Golden-AMI-Instance-${count.index + 1}"  
  }
}