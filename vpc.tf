resource "aws_vpc" "this" {
  cidr_block           = var.vpc_subnet
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    {
      "Name"                                      = var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.additional_tags
  )
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name         = var.dhcp_options_domain_name
  domain_name_servers = var.dhcp_options_domain_name_servers
  ntp_servers         = var.dhcp_options_ntp_servers
  tags = merge(
    {
      "Name"                                      = var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.additional_tags
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name"                                      = var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.additional_tags
  )
}

resource "aws_eip" "this" {
  count = 2
  vpc   = true
  tags = merge(
    {
      "Name"                                      = "${var.cluster_name}-nat-gw",
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "Service"                                   = "${var.cluster_name}-nat-gw"
    },
    var.additional_tags
  )
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = 2
  allocation_id = aws_eip.this.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  tags = merge(
    {
      "Name"                                      = var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.additional_tags
  )
  depends_on = [
    aws_internet_gateway.this,
    aws_eip.this,
    aws_subnet.public
  ]
}
