resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-control-plane.arn
  version  = var.kubernetes_version
  vpc_config {
    security_group_ids = [aws_security_group.eks-control-plane.id]
    subnet_ids         = data.aws_subnet_ids.private.ids
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-control-plane-cluster-policy,
    aws_iam_role_policy_attachment.eks-control-plane-service-policy,
  ]
  lifecycle {
    ignore_changes = [vpc_config]
  }
}
