terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
data "aws_availability_zones" "available" {}

provider "http" {}