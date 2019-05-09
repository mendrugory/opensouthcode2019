resource "aws_iam_role" "role-cluster" {
  name = "${var.cluster_name}-role-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "policy-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.role-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "policy-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.role-cluster.name}"
}

resource "aws_eks_cluster" "eks-master-cluster" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.role-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-master-sg.id}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.policy-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.policy-cluster-AmazonEKSServicePolicy"
  ]
}

resource "aws_security_group" "eks-master-sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "cluster-ingress-workstation" {
  cidr_blocks       = ["0.0.0.0/0", "${var.admin_ip}/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 0
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-master-sg.id}"
  to_port           = 65535
  type              = "ingress"
}
