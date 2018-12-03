terraform {
  backend "s3" {
    bucket  = "videobattle-tf-states-eu-central-1"
    key     = "videobattle-aws/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = "true"
  }
}
