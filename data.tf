data "aws_region" "current" {}

data "aws_ami" "dp_web" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-data-pipeline-server 2018-02-22T*",
    ]
  }

  owners = [
    "self",
  ]
}
