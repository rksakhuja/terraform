resource "aws_subnet" "pub" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_public}"

  tags = {
    Name = "rohitPublic"
  }
}