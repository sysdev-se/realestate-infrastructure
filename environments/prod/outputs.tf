output "project_id" {
  description = "Project ID."
  value       = module.project.project_id
}

output "project_number" {
  description = "Project number."
  value       = module.project.project_number
}

output "artifact_registry" {
  description = "Base path for images: <this>/<image>:<tag>."
  value       = "${google_artifact_registry_repository.containers.location}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.containers.repository_id}"
}

output "api_url" {
  description = "realestate-api URL."
  value       = module.api.uri
}

output "api_deployer_service_account" {
  description = "Set as GCP_SERVICE_ACCOUNT in sysdev-se/realestate-api."
  value       = module.api_deployer.email
}
