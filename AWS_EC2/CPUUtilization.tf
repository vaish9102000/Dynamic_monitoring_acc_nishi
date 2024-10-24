
resource "aws_cloudwatch_metric_alarm" "CPUUtilization-Linux-Warning" {
  for_each = var.ec2_instances
  #for_each = data.aws_ebs_volumes.example.ids
  alarm_name                = "SSE_${each.value.owner}_${data.aws_instances.test.id}_${each.value.id}_CPUUtilization_[Warning]"
  comparison_operator       = var.CPUUtilization_comparison_operator
  evaluation_periods        = var.CPUUtilization_evaluation_periods
  # metric_name               = var.CPUUtilization_metric_name
  # namespace                 = var.CPUUtilization_namespace
  # period                    = var.CPUUtilization_period
  # statistic                 = var.CPUUtilization_statistic
  threshold                 = var.CPUUtilization_threshold_warning
  alarm_description         = "SSE AWS Cloudwatch alarm for EC2 : (${each.value.id})  on AWS Account: ${each.value.owner}_${data.aws_instances.test.id} with MetricName: CPUUtilization"
  actions_enabled           = "true"
  alarm_actions             = []
  ok_actions                =  []  
  insufficient_data_actions = []
  metric_query {
    id = "m1"
    account_id = each.value.owner
    return_data = "true"

    metric {
      metric_name = var.CPUUtilization_metric_name
      namespace   = var.CPUUtilization_namespace
      period      = var.CPUUtilization_period
      stat        = var.CPUUtilization_statistic


      dimensions = {
    InstanceId = each.value.id
      }
    }
  }
 
}
 
