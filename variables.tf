variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "Region to spin the EKS cluster in"
}

variable "vpc_subnet" {
  type        = string
  description = "VPC CIDR block"
  default     = "172.16.0.0/16"
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  type        = string
  default     = "group1001.local"
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = list(string)
  default     = ["169.254.169.123"]
}

variable "bastion_ipv4_address_list" {
  type        = list
  description = "Bastion host that'll have https access to the api server"
  default     = ["18.221.90.91/32"]
}

variable "tags" {
  description = "Default tags to apply to resources"
  type        = map
  default = {
    "foo" = "bar"
  }
}

variable "additional_tags" {
  type        = map
  description = "AWS tags to append to resources managed by this module"
  default = {
    Terraform = "True"
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version we'll be running on our clusters"
  default     = "1.14"
}

variable "worker_node_instance_size" {
  type        = string
  description = "Worker nodes instance size to be used"
  default     = "c5.large"
}

variable "worker_node_asg_configs" {
  type        = map
  description = "Worker nodes autoscaling group parameters"
  default = {
    max_size         = 5
    min_size         = 2
    desired_capacity = 2
  }
}

variable "worker_node_disk_size" {
  type        = string
  description = "Worker node root volume disk size"
  default     = "100"
}
variable "worker_node_disk_type" {
  type        = string
  description = "Worker node voumes disk type"
  default     = "gp2"
}

variable "worker_node_delete_disk_on_termination" {
  type        = bool
  description = "Wether or not delete worker node EBS volume upon termination"
  default     = true
}

variable "aws_profile" {
  type        = string
  description = "AWS profile baked into the EKS cluster kubeconfig"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair to access worker nodes"
}
