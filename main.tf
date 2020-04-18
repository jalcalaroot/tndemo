#VPC con 3 capas de subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # que le permite contar con 65.536 IPs privadas.
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
     Name = "main"
     env = "terraform"
  }
}
#-----------------------------------------------------------
#.......................
###Subnets Públicas### salida y entrada desde internet.
#.......................

#Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.128.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-1"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.144.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-2"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 3
resource "aws_subnet" "public-subnet-3" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.160.0/20"	
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-3"
    env       = "terraform"
    layer     = "public"
  }
}

#------------------------------------------------------------
###############################
## Internet_gateway and route table
###############################

resource "aws_internet_gateway" "main-igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name      = "main-igw"
    env       = "terraform"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-igw.id}" 
  }

  tags = {
    Name      = "public-rt"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "public-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.public-subnet-1.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.public-subnet-2.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-3" {
  subnet_id      = "${element(aws_subnet.public-subnet-3.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


#--------------------------------------------------------------
#..................
#Private Subnets A = con salida a internet sin acceso desde internet.
#..................
 
#Public Subnet A1
resource "aws_subnet" "private-subnet-A1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A1"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A2
resource "aws_subnet" "private-subnet-A2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.32.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A2"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A3
resource "aws_subnet" "private-subnet-A3" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.64.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A3"
    env       = "terraform"
    layer     = "private"
  }
}
#--------------------------------------------------------------
###########################
# Nat Gateways x 3 HA
###########################

resource "aws_eip" "natgw-A1" {
  vpc = true
  tags = {
    Name = "natgw-A1"
  }
}

resource "aws_nat_gateway" "natgw-A1" {
  allocation_id = "${aws_eip.natgw-A1.id}"
  subnet_id     = "${aws_subnet.public-subnet-1.id}"
  tags = {
    Name = "natgw-A1"
  }
}


resource "aws_route_table" "private-rt-A1" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-A1.id}"
  }

  tags = {
    Name      = "private-rt-A1"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.private-subnet-A1.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-A1.id}"
}

#-----------------------------------------

resource "aws_eip" "natgw-A2" {
  vpc = true
  tags = {
    Name = "natgw-A2"
  }
}

resource "aws_nat_gateway" "natgw-A2" {
  allocation_id = "${aws_eip.natgw-A2.id}"
  subnet_id     = "${aws_subnet.public-subnet-2.id}"
  tags = {
    Name = "natgw-A2"
  }
}


resource "aws_route_table" "private-rt-A2" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-A2.id}"
  }

  tags = {
    Name      = "private-rt-A2"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.private-subnet-A2.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-A2.id}"
}
  
#--------------------------------------------------------

resource "aws_eip" "natgw-A3" {
  vpc = true
  tags = {
    Name = "natgw-A3"
  }
}

resource "aws_nat_gateway" "natgw-A3" {
  allocation_id = "${aws_eip.natgw-A3.id}"
  subnet_id     = "${aws_subnet.public-subnet-3.id}"
  tags = {
    Name = "natgw-A3"
  }
}

resource "aws_route_table" "private-rt-A3" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-A3.id}"
  }

  tags = {
    Name      = "private-rt-A3"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-3" {
  subnet_id      = "${element(aws_subnet.private-subnet-A3.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-A3.id}"
}

#---------------------------------------------------------
#..................
#Private Subnets B = sin salida ni entrada (internet)
#..................

#Private Subnet B1
resource "aws_subnet" "private-subnet-B1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.192.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B1"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B2
resource "aws_subnet" "private-subnet-B2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.200.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B2"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B3
resource "aws_subnet" "private-subnet-B3" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.208.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B3"
    env       = "terraform"
    layer     = "private"
  }
}

resource "aws_route_table" "private-rt-B" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name      = "private-rt-B"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private2-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.private-subnet-B1.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-B.id}"
}

resource "aws_route_table_association" "private2-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.private-subnet-B2.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-B.id}"
}

resource "aws_route_table_association" "private2-subnets-assoc-3" {
  subnet_id      = "${element(aws_subnet.private-subnet-B3.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-B.id}"
}
#----------------------------------------------------------
#EC2-SG
resource "aws_security_group" "ec2_sg" {
  name = "ec2_sg"
  description = "ec2_sg"
  vpc_id      = "${aws_vpc.main.id}"

  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }   
# ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"]
  }
# http
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"]
  }   
# https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"]
  }
  tags = {
    name = "ec2_sg"
    env  = "terraform"
  } 
}
#-----------------------------------------------------------
resource "aws_key_pair" "main_public_key" {
  key_name = "main_public_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7f56ewMZz4WLRzKLy8mnJ2ZS1gWhDiE3A4UinEqlogZQCuibNRSsF8C9oXg6IlxdeqBet5Zx4jf/qgTuEDVCF7QyyYxFtNKctSX901spJXhpusx4k9aMPmsTHGCj7DL1mHKwrvb7fSdJcsffo8R/3NWzP7bBcwLgZeTw/vSYvECNnco7yvPhIiHSvTfggj8s4tVEMb8vqkvfDJm6gRTpw3+KsA2yZGuiSFNQQcpbckVwbP5iSbalmJkRBPV5PWVx1wYLkSuPY4b6wAYyggfJ50rRO5Pvs7xhyJ7cXxTflE1OalZNpSLkAErYn4uuiW6az4BMHTB2aTVt98JEeoIwF jalcalaroot@jalcalaroot-VIT-P2412"
}
#----------------------------------------------------------
#IAM Role (para acceder a las instancias via Sesion Manager)

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#atachando policys 
resource "aws_iam_role_policy_attachment" "ssm" {
    role       = "${aws_iam_role.ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
    role       = "${aws_iam_role.ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name  = "ec2-instance-profile"
  role = "${aws_iam_role.ec2_role.name}"
}

#----------------------------------------------------------
# Server01 NGINX
resource "aws_instance" "Server01" {
  ami = "ami-07ebfd5b3428b6f4d"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-instance-profile.name}"
  key_name = "main_public_key"
  vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]
  subnet_id = "${aws_subnet.private-subnet-A1.id}"
  instance_type = "t2.small"
  user_data = "${file("deploy_nginx.sh")}"
  root_block_device {
  volume_type = "gp2"
  volume_size = 30
  }

  tags = {
    Name = "Server01"
  }
 }

# Server02 APACHE
resource "aws_instance" "Server02" {
  ami = "ami-07ebfd5b3428b6f4d"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-instance-profile.name}"
  key_name = "main_public_key"
  vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]
  subnet_id = "${aws_subnet.private-subnet-A1.id}"
  instance_type = "t2.small"
  user_data = "${file("deploy_apache.sh")}"
  root_block_device {
  volume_type = "gp2"
  volume_size = 30
  }

  tags = {
    Name = "Server02"
  }
 }
#-----------------------------------------------------------
#ALB-SG
resource "aws_security_group" "alb_sg" {
  name = "alb_sg"
  description = "alb_sg"
  vpc_id      = "${aws_vpc.main.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    name = "alb_sg"
    env  = "terraform"
  }
}
#------------------------------------------------------
#ALB
resource "aws_alb" "main-load-balancer" {
    name                = "main-load-balancer"
    security_groups     = ["${aws_security_group.alb_sg.id}"]
    subnets             = ["${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}", "${aws_subnet.public-subnet-3.id}"]

    tags {
      Name = "main-load-balancer"
    }
}
     output "elb_dns_name" {
     value = "${aws_alb.main-load-balancer.dns_name}"
 }

resource "aws_alb_target_group" "main-target" {
    name                = "main-target"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${aws_vpc.main.id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_alb.main-load-balancer"]
}


resource "aws_alb_listener" "main-alb-listener" {
    load_balancer_arn = "${aws_alb.main-load-balancer.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.main-target.arn}"
        type             = "forward"
    }
}

#Instances Attachments
resource "aws_alb_target_group_attachment" "ServerNginx" {
  target_group_arn = "${aws_alb_target_group.main-target.arn}"
  target_id        = "${aws_instance.Server01.id}"  
  port             = 80
}

resource "aws_alb_target_group_attachment" "ServerApache" {
  target_group_arn = "${aws_alb_target_group.main-target.arn}"
  target_id        = "${aws_instance.Server02.id}"
  port             = 80
}

