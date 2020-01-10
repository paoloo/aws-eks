resource "aws_iam_role" "eks-shared-cluster-admin" {
  name               = "${var.cluster_name}-shared-cluster-admin"
  path               = "/"
  assume_role_policy = file("${path.module}/files/admin_users_assume_role_policy.json")
  tags = merge(
    {
      "Name" = var.cluster_name,
    },
    var.additional_tags
  )
}

resource "aws_iam_role" "eks-cluster-admin" {
  name               = "${var.cluster_name}-cluster-admin"
  path               = "/"
  assume_role_policy = data.template_file.eks-cluster-admin.rendered
}

resource "aws_iam_role" "eks-cluster-control-plane" {
  name               = "${var.cluster_name}-eks-cluster-control-plane-iam-role"
  assume_role_policy = file("${path.module}/files/control_plane_assume_role_policy.json")
  tags = merge(
    {
      "Name" = var.cluster_name,
    },
    var.additional_tags
  )
}

resource "aws_iam_role" "eks-cluster-workers" {
  name               = "${var.cluster_name}-eks-cluster-workers-iam-role"
  assume_role_policy = file("${path.module}/files/worker_assume_role_policy.json")
  tags = merge(
    {
      "Name" = var.cluster_name,
    },
    var.additional_tags
  )
}

resource "aws_iam_instance_profile" "eks-worker-instance-profile" {
  name = "${var.cluster_name}-worker-instance-profile"
  role = aws_iam_role.eks-cluster-workers.name
}

resource "aws_iam_role_policy_attachment" "eks-control-plane-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-control-plane.name
}

resource "aws_iam_role_policy_attachment" "eks-control-plane-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-control-plane.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-cluster-workers.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cluster-workers.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-ecr-ro" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-cluster-workers.name
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = aws_eks_cluster.this.identity.0.oidc.0.issuer
}
