variable "aws_access_key" {
 description = "The AWS_ACCESS_KEY_ID to use"
}

variable "aws_secret_key" {
 description = "The AWS_SECRET_ACCESS_KEY to use"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-1"
}

resource "aws_vpc" "vpc_myapp_prod" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "vpc_myapp_prod"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }
}

resource "aws_subnet" "subnet_myapp_prod_10_1_0" {
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.1.0.0/22"
  tags {
    Name = "subnet_myapp_prod_0"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }
  depends_on = [ "aws_vpc.vpc_myapp_prod" ]
}

resource "aws_subnet" "subnet_myapp_prod_10_1_4" {
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"
  availability_zone = "us-east-1c"
  cidr_block = "10.1.4.0/22"
  tags {
    Name = "subnet_myapp_prod_4"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }
  depends_on = [ "aws_vpc.vpc_myapp_prod" ]
}

resource "aws_subnet" "subnet_myapp_prod_10_1_8" {
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"
  availability_zone = "us-east-1d"
  cidr_block = "10.1.8.0/22"
  tags {
    Name = "subnet_myapp_prod_4"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }
  depends_on = [ "aws_vpc.vpc_myapp_prod" ]
}

resource "aws_subnet" "subnet_myapp_prod_10_1_12" {
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"
  availability_zone = "us-east-1e"
  cidr_block = "10.1.12.0/22"
  tags {
    Name = "subnet_myapp_prod_12"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }
  depends_on = [ "aws_vpc.vpc_myapp_prod" ]
}

resource "aws_internet_gateway" "igw_myapp_prod" {
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"

  tags {
    Name = "igw_myapp_prod"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }
  depends_on = [ "aws_vpc.vpc_myapp_prod" ]
}

resource "aws_route_table" "rt_myapp_prod" {
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_myapp_prod.id}"
  }

  depends_on = [
     "aws_internet_gateway.igw_myapp_prod",
     "aws_vpc.vpc_myapp_prod"
  ]
}

resource "aws_route_table_association" "rta_myapp_prod_10_1_0" {
  subnet_id = "${aws_subnet.subnet_myapp_prod_10_1_0.id}"
  route_table_id = "${aws_route_table.rt_myapp_prod.id}"

  depends_on = [
    "aws_subnet.subnet_myapp_prod_10_1_0",
    "aws_route_table.rt_myapp_prod"
  ]
}

resource "aws_route_table_association" "rta_myapp_prod_10_1_4" {
  subnet_id = "${aws_subnet.subnet_myapp_prod_10_1_4.id}"
  route_table_id = "${aws_route_table.rt_myapp_prod.id}"

  depends_on = [
    "aws_subnet.subnet_myapp_prod_10_1_4",
    "aws_route_table.rt_myapp_prod"
  ]
}

resource "aws_route_table_association" "rta_myapp_prod_10_1_8" {
  subnet_id = "${aws_subnet.subnet_myapp_prod_10_1_8.id}"
  route_table_id = "${aws_route_table.rt_myapp_prod.id}"

  depends_on = [
    "aws_subnet.subnet_myapp_prod_10_1_8",
    "aws_route_table.rt_myapp_prod"
  ]
}

resource "aws_route_table_association" "rta_myapp_prod_10_1_12" {
  subnet_id = "${aws_subnet.subnet_myapp_prod_10_1_12.id}"
  route_table_id = "${aws_route_table.rt_myapp_prod.id}"

  depends_on = [
    "aws_subnet.subnet_myapp_prod_10_1_12",
    "aws_route_table.rt_myapp_prod"
  ]
}

resource "aws_launch_configuration" "lc_myapp_prod" {
  name = "lc_myapp_prod"
  image_id = "ami-3e058d56"
  instance_type = "m3.xlarge"
  key_name = "myapp-prod"
  security_groups = [
    "${aws_security_group.sg_myapp_prod_self.id}",
    "${aws_security_group.sg_myapp_prod_coreos.id}"
  ]

  user_data = "${file("user-data.base64")}"

  depends_on = [ "aws_security_group.sg_myapp_prod_coreos" ]
}

resource "aws_autoscaling_group" "asg_myapp_prod" {
  availability_zones = ["us-east-1a","us-east-1c","us-east-1d","us-east-1e"]
  name = "asg_myapp_prod"
  max_size = 9
  min_size = 5
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 5
  force_delete = true
  launch_configuration = "${aws_launch_configuration.lc_myapp_prod.id}"
  health_check_grace_period = 60
  load_balancers = [ "elb-myapp-prod" ]
  vpc_zone_identifier = [
    "${aws_subnet.subnet_myapp_prod_10_1_0.id}",
    "${aws_subnet.subnet_myapp_prod_10_1_4.id}",
    "${aws_subnet.subnet_myapp_prod_10_1_8.id}",
    "${aws_subnet.subnet_myapp_prod_10_1_12.id}"
  ]

  depends_on = [
    "aws_launch_configuration.lc_myapp_prod",
    "aws_subnet.subnet_myapp_prod_10_1_0",
    "aws_subnet.subnet_myapp_prod_10_1_4",
    "aws_subnet.subnet_myapp_prod_10_1_8",
    "aws_subnet.subnet_myapp_prod_10_1_12"
  ]
}

resource "aws_elb" "elb_myapp_prod" {
  name = "elb-myapp-prod"

  subnets = [
    "${aws_subnet.subnet_myapp_prod_10_1_0.id}",
    "${aws_subnet.subnet_myapp_prod_10_1_4.id}",
    "${aws_subnet.subnet_myapp_prod_10_1_8.id}",
    "${aws_subnet.subnet_myapp_prod_10_1_12.id}"
  ]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::MYAWSIDNUMBER:server-certificate/myapp"
  }

  listener {
    instance_port = 2222
    instance_protocol = "TCP"
    lb_port = 2222
    lb_protocol = "TCP"
  }

  health_check {
    healthy_threshold = 4
    unhealthy_threshold = 2
   timeout = 5
    target = "HTTP:80/health-check"
    interval = 15
  }

  security_groups = ["${aws_security_group.sg_myapp_prod_elb.id}"]

  depends_on = [
    "aws_security_group.sg_myapp_prod_elb",
    "aws_subnet.subnet_myapp_prod_10_1_0",
    "aws_subnet.subnet_myapp_prod_10_1_4",
    "aws_subnet.subnet_myapp_prod_10_1_8",
    "aws_subnet.subnet_myapp_prod_10_1_12"
  ]
}

resource "aws_security_group" "sg_myapp_prod_elb" {
  name = "sg_myapp_prod_elb"
  description = "Allow inbound ELB traffic"
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 2222
      to_port = 2222
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg_myapp_prod_elb"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }

  depends_on = [ "aws_vpc.vpc_myapp_prod" ]
}

resource "aws_security_group" "sg_myapp_prod_coreos" {
  name = "sg_myapp_prod_coreos"
  description = "Allow inbound CoreOS traffic"
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = [ "${aws_security_group.sg_myapp_prod_elb.id}" ]
  }
  ingress {
      from_port = 2222
      to_port = 2222
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = [ "${aws_security_group.sg_myapp_prod_elb.id}" ]
  }

  tags {
    Name = "sg_myapp_prod_coreos"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }

  depends_on = [
    "aws_vpc.vpc_myapp_prod",
    "aws_security_group.sg_myapp_prod_elb"
  ]
}

resource "aws_security_group" "sg_myapp_prod_self" {
  name = "sg_myapp_prod_igress"
  description = "Allow unfettered node-to-node traffic"
  vpc_id = "${aws_vpc.vpc_myapp_prod.id}"

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "-1"
      self = true
      security_groups = [ "${aws_security_group.sg_myapp_prod_coreos.id}" ]
  }

  tags {
    Name = "sg_myapp_prod_self"
    Environment = "myapp_prod"
    Application = "myapp"
    Lifecycle = "prod"
  }

  depends_on = [
    "aws_vpc.vpc_myapp_prod",
    "aws_security_group.sg_myapp_prod_coreos"
  ]
}

resource "aws_route53_zone" "primary" {
  name = "mb-myapp.com"
}

resource "aws_route53_record" "deis" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "deis.mb-myapp.com"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.elb_myapp_prod.dns_name}"]

  depends_on = [
    "aws_route53_zone.primary",
    "aws_elb.elb_myapp_prod"
  ]
}
