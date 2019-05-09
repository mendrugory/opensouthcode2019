variable "appserver_port" {
  default=80
}

variable "lb_availability_zones" {
  type = "list"
}

variable "appservers" {
  type = "list"
}
