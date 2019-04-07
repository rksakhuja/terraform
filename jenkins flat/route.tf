resource "aws_route_table" "pub" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"   
    gateway_id = "${aws_internet_gateway.gw.id}"
}
 tags = {
    Name = "public"
  }
}
resource "aws_route_table_association" "publicRTA" {
  subnet_id      = "${aws_subnet.pub.id}"
  route_table_id = "${aws_route_table.pub.id}"
}