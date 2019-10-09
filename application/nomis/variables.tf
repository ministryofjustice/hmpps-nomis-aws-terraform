variable "environment_name" {
  type = "string"
}

variable "short_environment_name" {
  type = "string"
}

variable "project_name" {
  description = "The project name - nomis-core"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "weblogic_domain_ports" {
  type        = "map"
  description = "Map of the ports that the weblogic domains use"
}

variable "instance_type_weblogic" {
  description = "The ec2 instance type"
}

variable "instance_count_weblogic_nomis" {
  description = "The desired number of weblogic instances"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "default_ansible_vars" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars"
  type        = "map"
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = "map"
}

variable "tags" {
  type = "map"
}

variable "nomis_haproxy_instance_type" {
  type        = "string"
  description = "Instance type to use for the proxy servers sitting between the external and internal load-balancers"
}

variable "nomis_haproxy_instance_count" {
  type        = "string"
  description = "Instance count to use for the proxy servers sitting between the external and internal load-balancers"
}
