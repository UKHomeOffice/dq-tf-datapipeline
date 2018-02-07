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

data "aws_ssm_parameter" "key_id" {
  name = "${var.environment}_default_kms_key_id"
}
