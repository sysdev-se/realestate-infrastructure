variable "project_id" {
  description = "Project the deployer service account is created in."
  type        = string
}

variable "account_id" {
  description = "Service account ID (6-30 chars)."
  type        = string
}

variable "github_repository" {
  description = "Repository allowed to impersonate the service account, as owner/name."
  type        = string
}

variable "wif_pool_name" {
  description = "Workload identity pool (projects/NUMBER/locations/global/workloadIdentityPools/ID)."
  type        = string
}

variable "artifact_registry_location" {
  description = "Location of the Artifact Registry repository images are pushed to."
  type        = string
}

variable "artifact_registry_repository" {
  description = "Artifact Registry repository ID images are pushed to."
  type        = string
}

variable "cloud_run_location" {
  description = "Region of the Cloud Run service."
  type        = string
}

variable "cloud_run_service" {
  description = "Name of the Cloud Run service the repo deploys."
  type        = string
}

variable "vpc_subnetwork" {
  description = "Subnet the service attaches to, if any."
  type        = string
  default     = null
}

variable "runtime_service_account_id" {
  description = "Fully qualified ID of the service's runtime service account."
  type        = string
}
