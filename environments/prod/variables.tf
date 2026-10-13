variable "environment" {
  description = "Environment name (dev, test, stage, prod)."
  type        = string
}

variable "project_id" {
  description = "Globally unique ID of this environment's project."
  type        = string
}

variable "region" {
  description = "Region for all regional resources."
  type        = string
}

variable "folder_id" {
  description = "realestate folder (root-infrastructure: terraform output systems)."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID."
  type        = string
}

variable "wif_pool_name" {
  description = "GitHub workload identity pool (root-infrastructure: terraform output wif_pool_name)."
  type        = string
}

variable "all_users_ingress_tag_value" {
  description = "allUsersIngress=True tag value (root-infrastructure: terraform output all_users_ingress_tag_value)."
  type        = string
}
