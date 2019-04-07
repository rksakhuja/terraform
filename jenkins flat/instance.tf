
# pull ssh key from machine and assign it to "my-key"
resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"

}


resource "aws_eip" "lb" {
  instance                  = "${aws_instance.jenkinsms.id}"
  vpc                       = true
  associate_with_private_ip = "${aws_instance.jenkinsms.private_ip}"
  depends_on                = ["aws_internet_gateway.gw"]
}


resource "aws_instance" "jenkinsms" {
  ami                           = "ami-0080e4c5bc078760e"
  instance_type                 = "t2.micro"
  key_name                      = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids        = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address   = true
  subnet_id = "${aws_subnet.pub.id}"
  user_data =  <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum remove -y java
                sudo yum install -y java-1.8.0-openjdk
                sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
                sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
                sudo yum install jenkins -y
                sudo service jenkins start
                EOF
  tags = {
    Name = "RohitEC2"
  }
}
resource "aws_instance" "jenkinsslave" {
  ami                           = "ami-0080e4c5bc078760e"
  instance_type                 = "t2.micro"
  key_name                      = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids        = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address   = true
  subnet_id = "${aws_subnet.pub.id}"
#   user_data =  <<-EOF
#                 #!/bin/bash
#                 sudo yum update -y
#                 sudo yum remove -y java
#                 sudo yum install -y java-1.8.0-openjdk
#                 sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#                 sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
#                 sudo yum install jenkins -y
#                 sudo service jenkins start
#                 EOF
  tags = {
    Name = "Jenkins Slave"
  }
}
  resource "aws_security_group" "allow_all" {
  name = "allow_all"
  vpc_id = "${aws_vpc.main.id}"

  # SSH access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {  
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}




output "instance_public_master" {
  value = "${aws_eip.lb.public_dns}"
}
output "instance_public_slave" {
  value = "${aws_instance.jenkinsslave.public_dns}"
}
