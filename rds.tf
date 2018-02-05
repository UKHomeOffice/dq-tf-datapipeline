resource "aws_db_subnet_group" "rds" {
  name = "dp_rds_main_group"

  subnet_ids = [
    "${aws_subnet.data_pipe_apps.id}",
    "${aws_subnet.data_pipe_rds_az2.id}",
  ]

  tags {
    Name = "rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_subnet" "data_pipe_rds_az2" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_pipe_rds_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az2}"

  tags {
    Name = "rds-subnet-az2-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_pipe_rt_az2" {
  subnet_id      = "${aws_subnet.data_pipe_rds_az2.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_security_group" "dp_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-db-${local.naming_suffix}"
  }

  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.opssubnet_cidr_block}",
      "${var.peering_cidr_block}",
    ]
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

resource "random_string" "username" {
  length  = 8
  number  = false
  special = false
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mssql_2012" {
  identifier              = "rds-mssql2012-${local.naming_suffix}"
  allocated_storage       = 200
  storage_type            = "gp2"
  engine                  = "sqlserver-se"
  engine_version          = "11.00.6594.0.v1"
  license_model           = "license-included"
  instance_class          = "db.m4.large"
  username                = "${random_string.username.result}"
  password                = "${random_string.password.result}"
  backup_window           = "00:00-01:00"
  maintenance_window      = "mon:01:30-mon:02:30"
  backup_retention_period = 14
  storage_encrypted       = true
  multi_az                = true
  skip_final_snapshot     = true

  db_subnet_group_name   = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids = ["${aws_security_group.dp_db.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "rds-mssql2012-${local.naming_suffix}"
  }
}
