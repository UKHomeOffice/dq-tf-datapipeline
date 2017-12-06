variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "appsvpc_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

variable "dp_postgres_ip" {
  description = "Mock EC2 database instance."
  default     = "10.1.8.11"
}

variable "dp_web_ip" {
  description = "Mock EC2 web instance."
  default     = "10.1.8.21"
}
