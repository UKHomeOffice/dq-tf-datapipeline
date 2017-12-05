locals {
  name_prefix = "${var.name_prefix}apps-data-pipeline-"
}

resource "aws_subnet" "data_pipe_apps" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_pipe_apps_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "${local.name_prefix}subnet"
  }
}

module "dp_postgres" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_pipe_apps.id}"
  user_data       = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_db=0.0.0.0:1433 LISTEN_rdp=0.0.0.0:3389"
  security_groups = ["${aws_security_group.dp_db.id}"]

  //  tags {
  //    Name = "${local.name_prefix}postgres"
  //  }
}

module "dp_web" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_pipe_apps.id}"
  user_data       = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_tcp=0.0.0.0:3389"
  security_groups = ["${aws_security_group.dp_web.id}"]

  //  tags {
  //    Name = "${local.name_prefix}web"
  //  }
}

resource "aws_security_group" "dp_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}db-sg"
  }

  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.opssubnet_cidr_block}",
    ]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.opssubnet_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dp_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}web-sg"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.opssubnet_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
