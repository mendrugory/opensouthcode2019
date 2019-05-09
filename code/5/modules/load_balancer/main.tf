resource "aws_security_group" "lb_sg" {
  name = "lb-security-group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "loadbalancer" {
  name               = "appserver-lb"
  availability_zones = ["${var.lb_availability_zones}"]
  security_groups    = ["${aws_security_group.lb_sg.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.appserver_port}"
    instance_protocol = "http"
  }

  instances                   = ["${var.appservers}"]
  cross_zone_load_balancing   = false
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 60
}
