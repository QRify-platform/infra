# Inherits the root AWS provider (do not nest provider "aws" here).

data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.qrify.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.qrify.name
}

