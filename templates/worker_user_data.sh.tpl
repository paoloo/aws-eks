#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${aws_eks_cluster_endpoint}' \
  --b64-cluster-ca '${aws_eks_cluster_ca}' \
  '${aws_eks_cluster_name}'
