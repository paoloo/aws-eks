resource "aws_route_table" "public" {
  count  = 2
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name"                                      = "${var.cluster_name}-public",
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.additional_tags
  )
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name"                                      = "${var.cluster_name}-private"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.additional_tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count                  = 2
  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.this.*.id, count.index)
}

resource "aws_route" "private_nat_gateway" {
  count                  = 2
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
