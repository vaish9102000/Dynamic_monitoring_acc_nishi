resource "aws_cloudwatch_metric_alarm" "StatusCheckFailed_Instance-Linux" {
  for_each = var.ec2_instances
  #for_each = data.aws_ebs_volumes.example.ids
  alarm_name                = "SSE_${each.value.owner}_${data.aws_instances.test.id}_${each.value.id}_StatusCheckFailed_Instance_[Critical]"
  comparison_operator       = var.StatusCheckFailed_Instance_comparison_operator
  # metric_name               = var.StatusCheckFailed_Instance_metric_name
  evaluation_periods        = var.StatusCheckFailed_Instance_evaluation_periods
  # namespace                 = var.StatusCheckFailed_Instance_namespace
  # period                    = var.StatusCheckFailed_Instance_period
  # statistic                 = var.StatusCheckFailed_Instance_statistic
  threshold                 = var.StatusCheckFailed_Instance_threshold
  alarm_description         = "SSE AWS Cloudwatch alarm for EC2 : (${each.value.id})  on AWS Account: ${each.value.owner}_${data.aws_instances.test.id} with MetricName: StatusCheckFailed_Instance"
  actions_enabled           = "true"
  alarm_actions             = []
  ok_actions                =  []  
  insufficient_data_actions = []
  metric_query {
    id = "m1"
    account_id = each.value.owner
    return_data = "true"

    metric {
      metric_name = var.StatusCheckFailed_Instance_metric_name
      namespace   = var.StatusCheckFailed_Instance_namespace
      period      = var.StatusCheckFailed_Instance_period
      stat        = var.StatusCheckFailed_Instance_statistic


      dimensions = {
    InstanceId = each.value.id
      }
    }
  }
 
}
 