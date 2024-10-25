# # module "AWS_EC2" {
# #   source = "./AWS_EC2"
# # }
module "Lambda" {
  source = "./Lambda"
  SNS_TOPIC_ARN = module.Config.SNS_TOPIC_ARN
}




# module "s3" {
#   source = "./S3_SSE"
#   s3_bucket_arn = module.aws_s3_bucket.this_s3_bucket_arn
#   s3_bucket_name = module.aws_s3_bucket.this_s3_bucket_id
# }

# #module "Config" {
#  # source = "./Config"
# #}
# #module "Splunk_role" {
#  # source = "./Splunk_Role"
# #}

# module "aws_s3_bucket" {
#   source                = "terraform-aws-modules/s3-bucket/aws"
#   version               = "1.1.0"
#   bucket       = "sse-config-logs"

# }
# # locals {
# #   bucket_policy_json = data.aws_iam_policy_document.aws_bucket_policy.json
# # }
# output "bucket_name" {
#   value = module.aws_s3_bucket.this_s3_bucket_id
# }
 
 module "SNS-SQS" {
   source = "./SNS-SQS"
 }