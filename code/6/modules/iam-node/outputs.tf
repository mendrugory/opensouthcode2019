output "iam_instance_profile_name" {
  value = "${aws_iam_instance_profile.policy-node.name}"
}

output "aws_iam_role_node_arn" {
  value = "${aws_iam_role.role-node.arn}"
}
