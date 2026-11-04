# Images uploaded through realestate-api. Private (the org enforces public access prevention):
# realestate-api serves them at /api/v1/consumer/images/{name}.
#
# Demo data only: every object is deleted about a day after upload (the lifecycle rule runs
# asynchronously, so it can take up to another day). Lift the rule once listings are kept in a
# persistent database (see .agents/RE-3/cloud-sql-notes.md).
resource "google_storage_bucket" "images" {
  project  = module.project.project_id
  name     = "${module.project.project_id}-listing-images"
  location = var.region
  labels   = local.labels

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  # Deleted images are gone for good (soft delete would keep them, billed, for 7 days).
  soft_delete_policy {
    retention_duration_seconds = 0
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}

# Upload, read and delete (when a listing is deleted) objects in this bucket only.
resource "google_storage_bucket_iam_member" "api_images" {
  bucket = google_storage_bucket.images.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${module.api.runtime_service_account_email}"
}
