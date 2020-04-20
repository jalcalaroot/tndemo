output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
output "public-subnet-1" {
  value = "${aws_subnet.public-subnet-1.id}"
}
output "public-subnet-2" {
  value = "${aws_subnet.public-subnet-2.id}"
}
output "public-subnet-3" {
  value = "${aws_subnet.public-subnet-3.id}"
}
output "private-subnet-A1" {
  value = "${aws_subnet.private-subnet-A1.id}"
}
output "private-subnet-A2" {
  value = "${aws_subnet.private-subnet-A2.id}"
}
output "private-subnet-A3" {
  value = "${aws_subnet.private-subnet-A3.id}"
}
output "private-subnet-B1" {
  value = "${aws_subnet.private-subnet-B1.id}"
}
output "private-subnet-B2" {
  value = "${aws_subnet.private-subnet-B2.id}"
}
output "private-subnet-B3" {
  value = "${aws_subnet.private-subnet-B3.id}"
}
output "elb_dns_name" {
  value = "${aws_alb.main-load-balancer.dns_name}"
}
output "id_Server01" {
  value = "${aws_instance.Server01.id}"
}
output "id_Server02" {
  value = "${aws_instance.Server02.id}"
}

