output "name" {
  description = "Job name."
  value       = google_cloud_run_v2_job.this.name
}

output "runtime_service_account_id" {
  description = "Fully qualified ID of the runtime service account."
  value       = google_service_account.runtime.id
}

output "runtime_service_account_email" {
  description = "Email of the runtime service account."
  value       = google_service_account.runtime.email
}
