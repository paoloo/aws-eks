data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  name = var.region
}

data "aws_subnet_ids" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Tier = "Private"
  }
  depends_on = [aws_subnet.private]
}

data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Tier = "Public"
  }
  depends_on = [aws_subnet.public]
}

data "aws_ami" "eks-worker-ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.this.version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"]
}

data "template_file" "worker-user-data" {
  template = "${file("${path.module}/templates/worker_user_data.sh.tpl")}"
  vars = {
    aws_eks_cluster_endpoint = aws_eks_cluster.this.endpoint,
    aws_eks_cluster_ca       = aws_eks_cluster.this.certificate_authority.0.data
    aws_eks_cluster_name     = var.cluster_name
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"
  vars = {
    endpoint                    = aws_eks_cluster.this.endpoint
    ca_data                     = aws_eks_cluster.this.certificate_authority.0.data
    cluster_name                = var.cluster_name
    cluster_region              = var.region
    aws_profile                 = var.aws_profile
    administrators_iam_role_arn = aws_iam_role.eks-cluster-admin.arn

  }
}

data "template_file" "eks-cluster-admin" {
  template = "${file("${path.module}/templates/eks-cluster-admin-users-policy.json.tpl")}"
  vars = {
    current_account = data.aws_caller_identity.current.account_id
  }
}

data "template_file" "aws-auth-configmap" {
  template = "${file("${path.module}/templates/aws-auth-configmap.tpl")}"
  vars = {
    administrators_iam_role_arn = aws_iam_role.eks-cluster-admin.arn
    cluster_role_arn            = aws_iam_role.eks-cluster-workers.arn
  }
}

data "aws_iam_group" "administrators" {
  group_name = "Administrators"
}

data "aws_iam_policy_document" "admin_users_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "${aws_iam_role.eks-cluster-admin.arn}",
    ]
  }
}

data "external" "thumbprint" {
  program = [format("%s/files/get_thumbprint.sh", path.module), data.aws_region.current.name]
}
