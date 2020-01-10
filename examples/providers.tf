provider "aws" {
  version = "~> 2.38.0"
}

terraform {
  backend "remote" {
    organization = "group-1001"
    workspaces {
      name = "terraform-aws-gke-testing"
    }
  }
}
