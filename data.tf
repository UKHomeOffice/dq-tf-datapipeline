data "aws_region" "current" {
  current = true
}

data "aws_ami" "dp_web" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-data-pipeline-server 2018-02-08T17-10-53Z*",
    ]
  }

  owners = [
    "self",
  ]
}
