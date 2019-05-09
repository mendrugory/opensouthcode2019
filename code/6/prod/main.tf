provider "aws" {}

module "network" {
  source = "../modules/network"

  cluster_name                  = "${var.cluster_name}"
  route_table_association_count = "${var.route_table_association_count}"
  subnet_count                  = "${var.subnet_count}"
}

module "eks-master" {
  source = "../modules/eks-master"

  cluster_name = "${var.cluster_name}"
  vpc_id       = "${module.network.vpc_id}"
  subnet_ids   = ["${module.network.subnet_ids}"]
  admin_ip = "${var.admin_ip}"
}

module "iam-node" {
  source = "../modules/iam-node"

  cluster_name = "${var.cluster_name}"
}

module "eks-node" {
  source = "../modules/eks-node"

  cluster_name                      = "${var.cluster_name}"
  vpc_id                            = "${module.network.vpc_id}"
  subnet_ids                        = ["${module.network.subnet_ids}"]
  eks_cluster_version               = "${module.eks-master.eks_cluster_version}"
  instance_type                     = "${var.node_instance_class}"
  eks_cluster_endpoint              = "${module.eks-master.eks_cluster_endpoint}"
  eks_cluster_certificate_authority = "${module.eks-master.eks_cluster_certificate_authority}"
  autoscaling_desired_capacity      = "${var.autoscaling_desired_capacity}"
  autoscaling_max_size              = "${var.autoscaling_max_size}"
  autoscaling_min_size              = "${var.autoscaling_min_size}"
  iam_instance_profile_name         = "${module.iam-node.iam_instance_profile_name}"
  eks_cluster_security_group_id     = "${module.eks-master.security_group_id}"
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.iam-node.aws_iam_role_node_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}
