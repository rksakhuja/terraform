# configure vpc
resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true

    tags = {

    Name = "Jenkins - Rohit"

  }

}