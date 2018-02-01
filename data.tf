data "aws_region" "current" {
  current = true
}

data "aws_ami" "dp_web" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-data-pipeline-server*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_db_snapshot" "dp_db_snapshot" {
  most_recent            = true
  db_snapshot_identifier = "final-snapshot-rds-mssql2012-data-pipeline-apps-notprod-dq"
}
