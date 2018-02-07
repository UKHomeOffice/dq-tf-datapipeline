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

resource "aws_instance" "dp_web" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.dp_web.id}"
  instance_type               = "t2.large"
  iam_instance_profile        = "${aws_iam_instance_profile.data_pipeline.id}"
  vpc_security_group_ids      = ["${aws_security_group.dp_web.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_pipe_apps.id}"
  private_ip                  = "${var.dp_web_private_ip}"

  user_data = <<EOF
  <powershell>
  $WSPass = aws --region eu-west-2 ssm get-parameter --name wherescape_rds_user --query 'Parameter.Value' --output text --with-decryption
  Add-OdbcDsn -Name "WSDQ" -DriverName "SQL Server Native Client 11.0" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("Server=${aws_db_instance.mssql_2012.address}", "Username=wherescape", "Password=$WSPass", "Port=1433", "Trusted_Connection=Yes", "Database=WSDQ")
  Add-OdbcDsn -Name "DQ_db" -DriverName "DataDirect 7.1 Greenplum Wire Protocol" -DsnType "System" -Platform "64-bit" -SetPropertyValue @("Server=10.1.25.4, "Username=wherescape", "Trusted_Connection=Yes", "Database=DQ_db")
  </powershell>
EOF

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
