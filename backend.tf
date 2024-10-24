terraform {
  backend "s3" {
    bucket = "mybucketsse"
    key = "terraform.tfstate"
    region = "us-east-2"
  }
}