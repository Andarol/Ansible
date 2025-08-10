terraform {
  backend "s3" {
    bucket = "peexbucket1"
    key    = "asg/terraform.tfstate"
    region = "eu-central-1"
  }
}