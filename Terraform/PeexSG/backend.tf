terraform {
  backend "s3" {
    bucket = "peexbucket1"
    key    = "sg/terraform.tfstate"
    region = "eu-central-1"
  }
}
