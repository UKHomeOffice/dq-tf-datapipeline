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
    "093401982388",
  ]
}
