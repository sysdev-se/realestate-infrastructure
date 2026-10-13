output "project_id" {
  description = "The project ID. Depends on the APIs being enabled."
  value       = google_project.this.project_id

  depends_on = [google_project_service.this]
}

output "project_number" {
  description = "The project number."
  value       = google_project.this.number
}
