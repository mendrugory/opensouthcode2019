output "dns_name" {
    value = "${aws_elb.loadbalancer.dns_name}"
}