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
    "ami-037774efca2da0726",  # Golden AMI 1
    "ami-008687c5b5546727c",  # Golden AMI 2
    "ami-050cd642fd83388e4",  # Golden AMI 3
  ]
}