provider "aws" {

}


# provider "aws" {
#     alias = "monitoring_account"
#   # not declaring an alias here so that us-east-1 is the "default"
#   region = var.aws_region
# assume_role {
#     role_arn = "arn:aws:iam::566481986706:role/AssumeRole-Devlopment-Account"
#     external_id = "cross_account"
#   }
# }