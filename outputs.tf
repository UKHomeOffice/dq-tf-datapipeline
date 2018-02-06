output "appsvpc_id" {
  value = "${var.appsvpc_id}"
}

output "opssubnet_cidr_block" {
  value = "${var.opssubnet_cidr_block}"
}

output "appsvpc_cidr_block" {
  value = "${var.appsvpc_cidr_block}"
}

output "data_pipe_apps_cidr_block" {
  value = "${var.data_pipe_apps_cidr_block}"
}

output "az" {
  value = "${var.az}"
}

output "dp_postgres_ip" {
  value = "${var.dp_postgres_ip}"
}

output "dp_web_ip" {
  value = "${var.dp_web_ip}"
}

output "iam_roles" {
  value = ["${aws_iam_role.data_pipeline_iam_role.id}"]
}

output "win_instance_id" {
  value = "${aws_instance.dp_web.id}"
}
