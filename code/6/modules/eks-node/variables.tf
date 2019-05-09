variable "cluster_name" {}
variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "eks_cluster_version" {}

variable "owners" {
  default     = ["602401143452"]
  description = "Amazon EKS AMI Account ID"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "eks_cluster_endpoint" {}
variable "eks_cluster_certificate_authority" {}
variable "eks_cluster_security_group_id" {}
variable "iam_instance_profile_name" {}

variable "autoscaling_desired_capacity" {
  default = 2
}

variable "autoscaling_max_size" {
  default = 2
}

variable "autoscaling_min_size" {
  default = 1
}
