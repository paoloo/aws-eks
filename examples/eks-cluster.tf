module "test" {
  source       = ".."
  version      = "1.2.29"
  cluster_name = "test"
  region       = "us-west-2"
  aws_profile  = "rnb"
  key_name     = "operations"
  additional_tags = {
    "Service"      = "Terraform CI testing"
    "Environment"  = "CI"
    "Onwer"        = "Paolo Oliveira"
    "cluster-name" = "test"
  }
}
