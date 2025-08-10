terraform {
  backend "s3" {
    bucket = "peexbucket1"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}