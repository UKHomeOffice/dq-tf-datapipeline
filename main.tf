locals {
  naming_suffix = "data-pipeline-${var.naming_suffix}"
}

resource "aws_subnet" "data_pipe_apps" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_pipe_apps_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_pipe_rt_association" {
  subnet_id      = "${aws_subnet.data_pipe_apps.id}"
  route_table_id = "${var.route_table_id}"
}

module "dp_postgres" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_pipe_apps.id}"
  user_data       = "LISTEN_db=0.0.0.0:1433 LISTEN_rdp=0.0.0.0:3389"
  security_groups = ["${aws_security_group.dp_db.id}"]
  private_ip      = "${var.dp_postgres_ip}"

  tags = {
    Name = "sql-server-${local.naming_suffix}"
  }
}

module "dp_web" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_pipe_apps.id}"
  user_data       = "LISTEN_tcp=0.0.0.0:3389 CHECK_db=${var.dp_postgres_ip}:1433"
  security_groups = ["${aws_security_group.dp_web.id}"]
  private_ip      = "${var.dp_web_ip}"

  tags = {
    Name = "wherescape-test-${local.naming_suffix}"
  }
}

resource "aws_instance" "dp_web" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.dp_web.id}"
  instance_type               = "t2.micro"
  iam_instance_profile        = "${aws_iam_instance_profile.data_pipeline.id}"
  vpc_security_group_ids      = ["${aws_security_group.dp_web.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_pipe_apps.id}"
  private_ip                  = "${var.dp_web_private_ip}"

  tags = {
    Name = "wherescape-${local.naming_suffix}"
  }
}

resource "aws_security_group" "dp_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-${local.naming_suffix}"
  }

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
