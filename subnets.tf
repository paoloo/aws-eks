resource "aws_subnet" "public" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = merge(
    {
      "Name"                                      = var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "Tier"                                      = "Public"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "private" {
  count             = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 10)
  vpc_id            = aws_vpc.this.id
  tags = merge(
    {
      "Name"                                      = var.cluster_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "Tier"                                      = "Private"
    },
    var.additional_tags
  )
}
