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
  include_shared         = true
  snapshot_type          = "shared"
  db_snapshot_identifier = "metadata-loaded"
}
