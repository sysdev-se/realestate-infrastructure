variable "project_id" {
  description = "Project the job is created in."
  type        = string
}

variable "region" {
  description = "Region of the job and its schedule."
  type        = string
}

variable "name" {
  description = "Job name; also used as the runtime service account ID (6-30 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.name))
    error_message = "name must be 6-30 lowercase letters, digits or hyphens."
  }
}

variable "initial_image" {
  description = "Image used when the job is first created."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/job"
}

variable "cpu" {
  description = "CPU limit of the task."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory limit of the task."
  type        = string
  default     = "512Mi"
}

variable "timeout" {
  description = "Maximum run time of one execution, e.g. \"1800s\"."
  type        = string
  default     = "1800s"
}

variable "max_retries" {
  description = "Times a failed execution is retried."
  type        = number
  default     = 0
}

variable "env" {
  description = "Plain environment variables."
  type        = map(string)
  default     = {}
}

variable "schedule" {
  description = "Cron schedule of the job (in time_zone). null = run by hand only."
  type        = string
  default     = null
}

variable "time_zone" {
  description = "Time zone of the schedule."
  type        = string
  default     = "Asia/Ho_Chi_Minh"
}

variable "labels" {
  description = "Labels applied to the job."
  type        = map(string)
  default     = {}
}
