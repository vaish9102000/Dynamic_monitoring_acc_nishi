# ################# CPUUtilization #####################
variable "CPUUtilization_comparison_operator" {
    type =  string
    default = "GreaterThanOrEqualToThreshold"
  
}

variable "CPUUtilization_period" {
    type = number
    default = 300
}

variable "CPUUtilization_metric_name" {
    type = string
    default = "CPUUtilization"
  
}

variable "CPUUtilization_statistic" {
    type =  string
    default = "Average"
  
}

variable "CPUUtilization_namespace" {
    type =  string
    default = "AWS/EC2"
}

variable "CPUUtilization_threshold_warning" {
    type = number
    default = 85
}
variable "CPUUtilization_threshold_critical" {
    type = number
    default = 90
}

variable "CPUUtilization_evaluation_periods" {
    type = number
    default = 3
  
}

# variable "CPUUtilization_alarm_description" {
#     type =  string
#     default = "Alarm for High CPU Usage"
  
# }



############### StatusCheckFailed_Instance #########################

variable "StatusCheckFailed_Instance_comparison_operator" {
    type =  string
    default = "GreaterThanOrEqualToThreshold"
  
}

variable "StatusCheckFailed_Instance_metric_name" {
    type =  string
    default = "StatusCheckFailed_Instance"
  
}

variable "StatusCheckFailed_Instance_period" {
    type = number
    default = 300
}


variable "StatusCheckFailed_Instance_statistic" {
    type =  string
    default = "Maximum"
  
}

variable "StatusCheckFailed_Instance_namespace" {
    type =  string
    default = "AWS/EC2"
}

variable "StatusCheckFailed_Instance_threshold" {
    type = number
    default = 1
}


variable "StatusCheckFailed_Instance_evaluation_periods" {
    type = number
    default = 1
  
}

############### StatusCheckFailed_System #########################


variable "StatusCheckFailed_System_comparison_operator" {
    type =  string
    default = "GreaterThanOrEqualToThreshold"
  
}

variable "StatusCheckFailed_System_metric_name" {
    type =  string
    default = "StatusCheckFailed_System"
  
}

variable "StatusCheckFailed_System_period" {
    type = number
    default = 300
}


variable "StatusCheckFailed_System_statistic" {
    type =  string
    default = "Maximum"
  
}

variable "StatusCheckFailed_System_namespace" {
    type =  string
    default = "AWS/EC2"
}

variable "StatusCheckFailed_System_threshold" {
    type = number
    default = 1
}


variable "StatusCheckFailed_System_evaluation_periods" {
    type = number
    default = 1
  
}

############### swap_used_percent #########################


variable "swap_used_percent_comparison_operator" {
    type =  string
    default = "GreaterThanThreshold"
  
}

variable "swap_used_percent_metric_name" {
    type =  string
    default = "swap_used_percent"
  
}

variable "swap_used_percent_period" {
    type = number
    default = 600
}


variable "swap_used_percent_statistic" {
    type =  string
    default = "Average"
  
}

variable "swap_used_percent_namespace" {
    type =  string
    default = "CWAgent"
}

variable "swap_used_percent_threshold" {
    type = number
    default = 50
}
variable "swap_used_percent_evaluation_periods" {
    type = number
    default = 3
  
}

variable "ec2_instances" {
  type    = map(object({
    id    = string
    owner = string
  }))
  default = {
    "AWFTLAMPRWBL002" = {
      id    = "i-07d9add56cd50186d",
      owner = "321569961463",
    }
    }
    }

