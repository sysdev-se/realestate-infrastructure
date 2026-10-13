variable "project_id" {
  description = "Globally unique project ID."
  type        = string
}

variable "project_name" {
  description = "Display name of the project."
  type        = string
}

variable "folder_id" {
  description = "Folder the project is created in (numeric ID)."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID."
  type        = string
}

variable "labels" {
  description = "Labels applied to the project."
  type        = map(string)
  default     = {}
}

variable "enabled_apis" {
  description = "APIs to enable in the project."
  type        = list(string)
  default = [
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}
