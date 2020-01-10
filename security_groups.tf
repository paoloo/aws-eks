resource "aws_security_group" "eks-control-plane" {
  name        = "${var.cluster_name}-control-plane"
  description = "EKS control plane rules"
  vpc_id      = aws_vpc.this.id
  tags = merge(
    { "Name" = "EKS Control Plane", "Terraform" = "True" },
    var.additional_tags
  )
}

resource "aws_security_group" "eks-worker-nodes" {
  name        = "${var.cluster_name}-worker-nodes"
  description = "EKS worker nodes rules"
  vpc_id      = aws_vpc.this.id
  tags = merge(
    { "Name" = "EKS Control Plane", "Terraform" = "True" },
    var.additional_tags
  )
}

resource "aws_security_group_rule" "eks-control-plane-https-inbound" {
  cidr_blocks       = var.bastion_ipv4_address_list
  description       = "Allow operators to communicate with the cluster API Server from withing our VPN"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-control-plane.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-control-plane-anywhere-outbound" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow control plane to communicate with everyone"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.eks-control-plane.id}"
  type              = "egress"
}

resource "aws_security_group_rule" "eks-worker-nodes-internal" {
  description              = "Allow worker nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-worker-nodes.id}"
  source_security_group_id = "${aws_security_group.eks-worker-nodes.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-nodes-to-control-plane" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-worker-nodes.id}"
  source_security_group_id = "${aws_security_group.eks-control-plane.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-nodes-to-control-plane-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-control-plane.id}"
  source_security_group_id = "${aws_security_group.eks-worker-nodes.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-nodes-anywhere-outbound" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow worker nodes to communicate with everyone"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.eks-worker-nodes.id}"
  type              = "egress"
}
