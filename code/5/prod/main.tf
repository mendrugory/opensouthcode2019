provider "aws" {
  //Londres
  region = "eu-west-2"
}

module "appserver" {
  source = "../modules/app_server"

  ami                 = "${var.ami}"
  number_of_appserver = "${var.number_of_appserver}"
  database_password   = "${var.database_password}"
  database_username   = "${var.database_username}"
  database_name       = "${var.database_name}"
  database_address    = "${module.database.address}"
  ec2_instance_class  = "${var.ec2_instance_class}"
}

module "database" {
  source = "../modules/datastore"

  database_name     = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  db_instance_class = "${var.db_instance_class}"
  allocated_storage = "${var.allocated_storage}"
}

data "aws_availability_zones" "all" {}

module "load_balancer" {
  source = "../modules/load_balancer"

  lb_availability_zones = ["${data.aws_availability_zones.all.names}"]
  appservers            = ["${module.appserver.instances}"]
}
