variable "SNS_TOPIC_ARN" {}

variable "selected_ami_index" {
  description = "Index of the selected Golden AMI (0-2)"
  type        = number
  default     = 0 
}

# Define input variable for AMI selection
variable "golden_ami_ids" {
  description = "List of Golden AMI IDs to choose from"
  type        = list(string)
  default     = [
    "ami-050cd642fd83388e4",  # Golden AMI 1
    "ami-0ea3c35c5c3284d82",  # Golden AMI 2
  ]
}