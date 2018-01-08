variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "appsvpc_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "peering_cidr_block" {}
variable "az" {}

variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "dp_postgres_ip" {
  description = "Mock EC2 database instance."
  default     = "10.1.8.11"
}

variable "dp_web_ip" {
  description = "Mock EC2 web instance."
  default     = "10.1.8.21"
}
