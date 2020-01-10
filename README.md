# Terrafrom Amazon Elastic Kubernetes Service module

This module handles an opinionated Amazon Elastic Kubernetes Service cluster
with it's required networking resources.

The resources that this module will manage are:

1. Create a VPC with all the underlying networking required to spin your cluster in it;
1. Create all the IAM policies, roles and instance profiles required to spin up your cluster;
1. Create an EKS cluster;
1. Create an EKS worker node ASG;

## Using this module

You can check the [examples](examples/eks-cluster.tf) on how to properly use this
module.

#### Testing this module's code

You can test it (and run the above mentioned examples) with the provided
Makefile:

```bash
$ cd examples/
$ terraform plan
```


#### Cleaning up this module's test bed

If you want to clean up after a run, you can just run the `clean` Make target
like so:

```bash
$ make clean
```
This script is kinda smart enough to figure out wether or not it should run a
terraform destroy or just clean up the modules

### Customizing this module
All the parameters in which you can change in this modules are described
[in the variables.tf file](variables.tf) in order to override them, simply
define the new values while importing the module. IE:

```hcl
module "test" {
  source       = ".."
  version      = "1.2.0"
  cluster_name = "rally-test"
  region       = "us-west-2"
  aws_profile  = "rnb"
  key_name     = "operations"
  additional_tags = {
    "Onwer"       = "Paolo Oliveira"
  }
}
```

Setting the `cluster_name` parameter to `rally-test` in this example will
create a EKS cluster with `rally-test` as it's name.
