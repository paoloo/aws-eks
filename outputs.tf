output "kubeconfig" {
  value = data.template_file.kubeconfig.rendered
}
output "aws-auth-configmap" {
  value = data.template_file.aws-auth-configmap.rendered
}
output "eks-worker-role" {
  value = aws_iam_role.eks-cluster-workers.name
}
output "oidc-url" {
  value = aws_eks_cluster.this.identity.0.oidc.0.issuer
}
output "oidc-arn" {
  value = aws_iam_openid_connect_provider.this.arn
}
