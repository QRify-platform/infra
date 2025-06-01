provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.qrify.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.qrify.name
}

