data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_id
}