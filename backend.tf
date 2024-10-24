terraform {
  backend "s3" {
    bucket = "tests3bucketfordevops"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}