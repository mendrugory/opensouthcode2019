provider "aws" {
  // Paris
  region = "eu-west-3"
}

resource "aws_instance" "server" {
  ami           = "ami-0dd7e7ed60da8fb83"
  instance_type = "t2.nano"
}
