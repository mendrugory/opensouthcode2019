output "security_group_id" {
  value = "${aws_security_group.eks-master-sg.id}"
}

output "eks_cluster_version" {
  value = "${aws_eks_cluster.eks-master-cluster.version}"
}

output "eks_cluster_endpoint" {
  value = "${aws_eks_cluster.eks-master-cluster.endpoint}"
}

output "eks_cluster_certificate_authority" {
  value = "${aws_eks_cluster.eks-master-cluster.certificate_authority.0.data}"
}
