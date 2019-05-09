resource "aws_security_group" "database_sg" {
  name = "database-security-group"

  ingress {
    from_port   = "3306"
    to_port     = "3306"
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

resource "aws_db_instance" "database" {
  engine                  = "mysql"
  allocated_storage       = "${var.allocated_storage}"
  instance_class          = "${var.db_instance_class}"
  name                    = "${var.database_name}"
  username                = "${var.database_username}"
  password                = "${var.database_password}"
  vpc_security_group_ids  = ["${aws_security_group.database_sg.id}"]
  backup_window           = "17:30-18:00"
  backup_retention_period = 2
  maintenance_window      = "Mon:01:00-Mon:04:00"
  skip_final_snapshot     = true
}