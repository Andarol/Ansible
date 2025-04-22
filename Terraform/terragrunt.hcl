terraform {
  source = "./"
}

remote_state {
  backend = "s3"
  config = {
    bucket = "bucket-for-studing"
    key    = "wordpress/terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}
