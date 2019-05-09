resource "aws_security_group" "eks-node-sg" {
  name        = "${var.cluster_name}-eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.cluster_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_cluster_version}-v*"]
  }

  most_recent = true
  owners      = "${var.owners}"
}

locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_cluster_endpoint}' --b64-cluster-ca '${var.eks_cluster_certificate_authority}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "eks-node-launch-config" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_instance_profile_name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.cluster_name}"
  security_groups             = ["${aws_security_group.eks-node-sg.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks-node-autoscaling-group" {
  desired_capacity     = "${var.autoscaling_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.eks-node-launch-config.id}"
  max_size             = "${var.autoscaling_max_size}"
  min_size             = "${var.autoscaling_min_size}"
  name                 = "${var.cluster_name}-autoscaling-group"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
