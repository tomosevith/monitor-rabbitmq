terraform {
  backend "s3" {
    bucket  = "videobattle-tf-states-eu-central-1"
    key     = "gitlab-runner/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = "true"
  }
}
