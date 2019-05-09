output "instances" {
  value = ["${aws_instance.appserver.*.id}"]
}
