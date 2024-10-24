resource "aws_cloudwatch_metric_alarm" "StatusCheckFailed_System-Linux" {
  for_each = var.ec2_instances
  alarm_name                = "SSE_${each.value.owner}_${data.aws_instances.test.id}_${each.value.id}_StatusCheckFailed_System_[Critical]"
  comparison_operator       = var.StatusCheckFailed_System_comparison_operator
  # metric_name               = var.StatusCheckFailed_System_metric_name
  evaluation_periods        = var.StatusCheckFailed_System_evaluation_periods
  # namespace                 = var.StatusCheckFailed_System_namespace
  # period                    = var.StatusCheckFailed_System_period
  # statistic                 = var.StatusCheckFailed_System_statistic
  threshold                 = var.StatusCheckFailed_System_threshold
  alarm_description         = "SSE AWS Cloudwatch alarm for EC2 : (${each.value.id}) on AWS Account: ${each.value.owner}_${data.aws_instances.test.id} with MetricName: StatusCheckFailed_System"
  actions_enabled           = "true"
  alarm_actions             = []
  ok_actions                =  []  
  insufficient_data_actions = []
  metric_query {
    id = "m1"
    account_id = each.value.owner
    return_data = "true"

    metric {
      metric_name = var.StatusCheckFailed_System_metric_name
      namespace   = var.StatusCheckFailed_System_namespace
      period      = var.StatusCheckFailed_System_period
      stat        = var.StatusCheckFailed_System_statistic


      dimensions = {
    InstanceId = each.value.id
      }
    }
  }
 
}
 