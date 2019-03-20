resource "aws_iam_role" "data_pipeline_iam_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com",
        "Service": "ssm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "data_pipeline_archive" {
  role = "${aws_iam_role.data_pipeline_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "${var.archive_bucket}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:ListObject"
      ],
      "Resource": "${var.archive_bucket}/*"
    },
    {
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "${var.bucket_key}"
    }
  ]
}
EOF
}

resource "aws_kms_key" "dp_pw_key" {
  description             = "DataPipeline Creds Key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_iam_role_policy" "iam_role_policy" {
  role = "${aws_iam_role.data_pipeline_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters",
                "ssm:DescribeParameter",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-2:*:parameter/wherescape_rds_user"
        },
        {
          "Effect": "Allow",
          "Action": "kms:Decrypt",
          "Resource": "${aws_kms_key.dp_pw_key.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "data_pipeline" {
  role = "${aws_iam_role.data_pipeline_iam_role.name}"
}
