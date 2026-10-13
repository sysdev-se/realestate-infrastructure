output "email" {
  description = "Email to configure as the repo's GCP service account."
  value       = google_service_account.this.email
}
