resource "aws_vpc" "vpc" {
  cidr_block = "172.18.0.0/16"

  tags = "${
    map(
     "Name", "${var.cluster_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet" {
  count = "${var.subnet_count}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "172.18.${count.index}.0/24"
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.cluster_name}"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count = "${var.route_table_association_count}"

  subnet_id      = "${aws_subnet.subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.route-table.id}"
}
