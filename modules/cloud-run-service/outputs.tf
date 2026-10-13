output "name" {
  description = "Service name."
  value       = google_cloud_run_v2_service.this.name
}

output "uri" {
  description = "Default https://*.run.app URL."
  value       = google_cloud_run_v2_service.this.uri
}

output "runtime_service_account_id" {
  description = "Fully qualified ID of the runtime service account."
  value       = google_service_account.runtime.id
}

output "runtime_service_account_email" {
  description = "Email of the runtime service account."
  value       = google_service_account.runtime.email
}
