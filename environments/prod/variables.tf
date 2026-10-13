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
