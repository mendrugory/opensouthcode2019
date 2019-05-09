resource "aws_security_group" "appserver_sg" {
  name = "appserver-security-group"

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

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "appserver_user_data" {
  template = "${file("${path.module}/appserver.sh")}"

  vars = {
    db_password       = "${var.database_password}"
    db_username       = "${var.database_username}"
    db_name           = "${var.database_name}"
    db_address        = "${var.database_address}"
  }
}

resource "aws_instance" "appserver" {
  ami                    = "${var.ami}"
  instance_type          = "${var.ec2_instance_class}"
  vpc_security_group_ids = ["${aws_security_group.appserver_sg.id}"]
  count                  = "${var.number_of_appserver}"
  user_data              = "${data.template_file.appserver_user_data.rendered}"

  tags {
    Name  = "appserver"
    Group = "appservers"
  }

  lifecycle {
    create_before_destroy = true
  }
}
