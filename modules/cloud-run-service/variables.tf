variable "project_id" {
  description = "Project the service is created in."
  type        = string
}

variable "project_number" {
  description = "Number of the project; used for the tag binding."
  type        = string
}

variable "region" {
  description = "Region of the service."
  type        = string
}

variable "name" {
  description = "Service name; also used as the runtime service account ID (6-30 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.name))
    error_message = "name must be 6-30 lowercase letters, digits or hyphens."
  }
}

variable "initial_image" {
  description = "Image used when the service is first created."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "container_port" {
  description = "Port the container listens on (also exposed to it as $PORT)."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU limit per instance."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory limit per instance."
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum instances. 0 scales to zero (cold starts, no idle cost)."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum instances."
  type        = number
  default     = 3
}

variable "env" {
  description = "Plain environment variables."
  type        = map(string)
  default     = {}
}

variable "secret_env" {
  description = "Environment variables read from Secret Manager: name => secret ID in this project."
  type        = map(string)
  default     = {}
}

variable "vpc_subnetwork" {
  description = "Subnet to attach via Direct VPC egress, for reaching private resources. null = no VPC access."
  type        = string
  default     = null
}

variable "project_roles" {
  description = "Project-level roles granted to the runtime service account."
  type        = list(string)
  default     = []
}

variable "public" {
  description = "Allow unauthenticated invocations."
  type        = bool
  default     = false
}

variable "all_users_ingress_tag_value" {
  description = "TagValue (tagValues/NNN) for allUsersIngress=True. Required when public = true."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels applied to the service."
  type        = map(string)
  default     = {}
}
