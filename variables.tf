variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "appsvpc_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

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

variable "service" {
  default     = "dq-data-pipeline"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment" {
  default     = "preprod"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment_group" {
  default     = "dq-apps"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}
