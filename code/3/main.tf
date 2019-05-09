provider "aws" {
  region = "eu-west-3"
}

data "template_file" "start_script" {
  template = "${file("./script.sh")}"
}

resource "aws_security_group" "server_sg" {
  name = "server-security-group"

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

resource "aws_instance" "server" {
  ami                    = "ami-0dd7e7ed60da8fb83"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.start_script.rendered}"
  vpc_security_group_ids = ["${aws_security_group.server_sg.id}"]
}

output "public_ip"{
  value = "${aws_instance.server.public_ip}"
}
